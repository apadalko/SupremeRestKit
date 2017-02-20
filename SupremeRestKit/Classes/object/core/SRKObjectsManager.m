//
//  SRKObjectManager.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <objc/message.h>
#import <objc/runtime.h>

#import "SRKObjectsManager.h"

#import "SRKObject_Private.h"






static CFNumberType SRKNumberFromType(const char *encodedType) {
    // To save anyone in the future from some major headaches, sanity check here.
#if kCFNumberTypeMax > UINT8_MAX
#error kCFNumberTypeMax has been changed! This solution will no longer work.
#endif
    
    static uint8_t types[128] = {
        
        ['c'] = kCFNumberCharType,
        ['i'] = kCFNumberIntType,
        ['s'] = kCFNumberShortType,
        ['l'] = kCFNumberLongType,
        ['q'] = kCFNumberLongLongType,
        
        
        ['C'] = kCFNumberCharType,
        ['I'] = kCFNumberIntType,
        ['S'] = kCFNumberShortType,
        ['L'] = kCFNumberLongType,
        ['Q'] = kCFNumberLongLongType,
        

        ['f'] = kCFNumberFloatType,
        ['d'] = kCFNumberDoubleType,
        

        ['B'] = kCFNumberCharType,
    };
    
    return (CFNumberType)types[encodedType[0]];
}
static NSNumber *SRKNumberSafe(const char *typeEncoding, const void *bytes) {
    if (typeEncoding[0] == 'B' || typeEncoding[0] == 'c') {
        return [NSNumber numberWithBool:*(BOOL *)bytes];
    }
    CFNumberType numberType = SRKNumberFromType(typeEncoding);
    return (__bridge_transfer NSNumber *)CFNumberCreate(NULL, numberType, bytes);
}





static BOOL startsWith(const char *string, const char *prefix) {
    for (; *string && *prefix && *prefix == *string; ++string, ++prefix)
        ;
    return !*prefix;
}
static objc_property_t genObjcProperty(Class klass, SEL sel, SEL outPair[2]) {
    const char *selName = sel_getName(sel);
    ptrdiff_t selNameByteLen = strlen(selName) + 1;
    char temp[selNameByteLen + 4];
    
    if (startsWith(selName, "set")) {
        outPair[1] = sel;
        memcpy(temp, selName + 3, selNameByteLen - 3);
        temp[0] -= 'A' - 'a';
        
        temp[selNameByteLen - 5] = 0; // drop ':'
        outPair[0] = sel_registerName(temp);
    } else {
        outPair[0] = sel;
        sprintf(temp, "set%s:", selName);
        if (selName[0] >= 'a' && selName[0] <= 'z') {
            temp[3] += 'A' - 'a';
        }
        outPair[1] = sel_registerName(temp);
    }
    const char *propName = sel_getName(outPair[0]);
    objc_property_t property = class_getProperty(klass, propName);
    if (!property) {
        memcpy(temp, propName, strlen(propName) + 1);
        temp[0] += 'A' - 'a';
        outPair[0] = sel_registerName(temp);
        property = class_getProperty(klass, temp);
    }
    return property;
}




@interface SRKObjectsManager ()
{
    dispatch_queue_t _dataAccessQueue;
    
    NSMutableDictionary *_savedProperties;
    NSMutableDictionary *_savedMethodSignatures;
    Class _objectClass;
    
}

@property (nonatomic,retain)NSMapTable  * mapTable;
@end
@implementation SRKObjectsManager

#pragma mark - chache storage

-(SRKObject*)registerOrGetRecentObjectFromStorage:(SRKObject*)object fetched:(BOOL)fetched{
    if (![object identifier]) {
        return object;
    }
    @synchronized (self.mapTable) {
        SRKObject * oldObj = [self.mapTable objectForKey:[object identifier]];
        
        if (!oldObj) {
            [self.mapTable setObject:object forKey:[object identifier]];
            return object;
        }else{
            return oldObj;
        }
    }
    
}

#pragma mark -
static NSMutableDictionary * _objectsManagers;
+(NSMutableDictionary*)objectsManagers{
    if (!_objectsManagers) {
        _objectsManagers=[[NSMutableDictionary alloc] init];
    }
    return _objectsManagers;
}
+(SRKObjectsManager*)objectManagerForClass:(Class)clazz{
    NSString * clName = NSStringFromClass(clazz);
    SRKObjectsManager * objController = [[self objectsManagers] valueForKey:clName];
    if (!objController) {
        objController=[[self alloc] initWithClass:clazz];
        [self objectsManagers][clName]=objController;
    }
    return objController;
}




-(instancetype)initWithClass:(Class)clazz{
    if (self=[super init]) {
        _dataAccessQueue = dispatch_queue_create("com.darkside.SRKObjectsManager", DISPATCH_QUEUE_SERIAL);
        _objectClass = clazz;
        self.mapTable=[NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        _savedProperties = [NSMutableDictionary dictionary];
        _savedMethodSignatures = [NSMutableDictionary dictionary];
    }
    return self;
    
}

#pragma mark - public
- (BOOL)forwardObjectInvocation:(NSInvocation *)invocation withObject:(SRKObject*)object{
    BOOL isSetter = NO;
    SRKProperty *property = [self propertyForSelector:invocation.selector isSetter:&isSetter];
    if (!property) {
        return NO;
    }
    if (isSetter) {
        [self _forwardSetterInvocation:invocation forProperty:property withObject:object];
    } else {
        [self _forwardGetterInvocation:invocation forProperty:property withObject:object];
    }
    return YES;
}
-(SRKProperty*)propertyForKey:(NSString*)key{
    __block SRKProperty * p = nil;
    dispatch_sync(_dataAccessQueue, ^{
        p = [self _propertyForName:key];
    });
    
    return p;
}
- (NSMethodSignature *)forwardingMethodSignatureForSelector:(SEL)cmd {
    __block NSMethodSignature *result = nil;
    NSString *selectorString = NSStringFromSelector(cmd);
    
    // NSMethodSignature can be fairly heavyweight, so let's agressively cache this here.
    dispatch_sync(_dataAccessQueue, ^{
        result = _savedMethodSignatures[selectorString];
        if (result) {
            return;
        }
        
        SRKProperty * property = [self _propertyForSelector:cmd];
        if (!property) {
            return;
        }
        BOOL isSetter = (cmd == property.setterSelector);
        
        NSString *objcTypes;
        if (property.isObjectType) {
            objcTypes = ([NSString stringWithFormat:(isSetter ? @"v@:%@" : @"%@@:"), @"@"]);
        }else {
            objcTypes = ([NSString stringWithFormat:(isSetter ? @"v@:%@" : @"%@@:"), property.code]);
        }
        
        result = [NSMethodSignature signatureWithObjCTypes:objcTypes.UTF8String];
        _savedMethodSignatures[selectorString] = result;
    });
    
    return result;
}


#pragma mark - private


- (void)_forwardGetterInvocation:(NSInvocation *)invocation
                     forProperty:(SRKProperty *)property
                      withObject:(SRKObject *)object {
    
    const char *methodReturnType = invocation.methodSignature.methodReturnType;
    void *returnValueBytes = alloca(invocation.methodSignature.methodReturnLength);
    
    __autoreleasing id dictionaryValue = nil;
    
    {
        dictionaryValue = object[property.propertyName];
        if (property.propertyForceType == SRKPropertyForceTypeCopy) {
            dictionaryValue = [dictionaryValue copy];
        }
    }
    
    if (dictionaryValue == nil || [dictionaryValue isKindOfClass:[NSNull class]]) {
        memset(returnValueBytes, 0, invocation.methodSignature.methodReturnLength);
    } else if (property.isObjectType) {
        memcpy(returnValueBytes, (void *) &dictionaryValue, sizeof(id));
    } else if ([dictionaryValue isKindOfClass:[NSNumber class]]) {
        CFNumberGetValue((__bridge CFNumberRef) dictionaryValue,
                         SRKNumberFromType(methodReturnType),
                         returnValueBytes);
    }
    
    [invocation setReturnValue:returnValueBytes];
}

- (void)_forwardSetterInvocation:(NSInvocation *)invocation
                     forProperty:(SRKProperty *)property
                      withObject:(SRKObject *)object {
    
    SRKObject *sourceObject = object;
    const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:2];
    
    NSUInteger argumentValueSize = 0;
    NSGetSizeAndAlignment(argumentType, &argumentValueSize, NULL);
    
    void *argumentValueBytes = alloca(argumentValueSize);
    [invocation getArgument:argumentValueBytes atIndex:2];
    
    id dictionaryValue = nil;
    if (property.isObjectType) {
        dictionaryValue = *(__unsafe_unretained id *)argumentValueBytes;
        if (property.propertyForceType == SRKPropertyForceTypeCopy) {
            dictionaryValue = [dictionaryValue copy];
        }
    } else {
        dictionaryValue = SRKNumberSafe(argumentType, argumentValueBytes);
    }
    
    
    
    if (dictionaryValue == nil) {
        [sourceObject removeObjectForKey:property.propertyName];
    } else {
        sourceObject[property.propertyName] = dictionaryValue;
    }
}


#pragma mark - get properties

#pragma mark FOR SELECTOR
- (SRKProperty *)propertyForSelector:(SEL)cmd isSetter:(BOOL *)isSetter {
    __block SRKProperty *result = nil;
    dispatch_sync(_dataAccessQueue, ^{
        result = [self _propertyForSelector:cmd];
    });
    
    if (isSetter) {
        *isSetter = (cmd == result.setterSelector);
    }
    
    return result;
}
- (SRKProperty *)_propertyForSelector:(SEL)cmd {
    SRKProperty *result = nil;
    NSString *selectorString = NSStringFromSelector(cmd);
    result = _savedProperties[selectorString];
    if (result) {
        return result;
    }
    
    SEL propertySelectors[2];
    objc_property_t property = genObjcProperty(_objectClass, cmd, propertySelectors);
    if (!property) {
        return nil;
    }
    
    NSString *propertyName = @(property_getName(property));
    result = _savedProperties[propertyName];
    if (result) {
        _savedProperties[selectorString] = result;
        return result;
    }
    
    
    
    result = [SRKProperty propertyWithSourceClass:_objectClass andName:propertyName];
    
    _savedProperties[result.propertyName] = result;
    if (result.getterSelector) {
        _savedProperties[NSStringFromSelector(result.getterSelector)] = result;
    }
    if (result.setterSelector) {
        _savedProperties[NSStringFromSelector(result.setterSelector)] = result;
    }
    
    return result;
}
#pragma mark FOR NAME


-(SRKProperty*)_propertyForName:(NSString*)name{
    SRKProperty *result = nil;
    NSString *selectorString = name;
    result = _savedProperties[selectorString];
    if (result) {
        return result;
    }
    
    SEL cmd = NSSelectorFromString(name);
    SEL propertySelectors[2];
    objc_property_t property = genObjcProperty(_objectClass, cmd, propertySelectors);
    if (!property) {
        return nil;
    }
    
    NSString *propertyName = @(property_getName(property));
    result = _savedProperties[propertyName];
    if (result) {
        _savedProperties[selectorString] = result;
        return result;
    }
    
    
    
    result = [SRKProperty propertyWithSourceClass:_objectClass andName:propertyName];
    
    _savedProperties[result.propertyName] = result;
    if (result.getterSelector) {
        _savedProperties[NSStringFromSelector(result.getterSelector)] = result;
    }
    if (result.setterSelector) {
        _savedProperties[NSStringFromSelector(result.setterSelector)] = result;
    }
    
    return result;
    
}

@end
