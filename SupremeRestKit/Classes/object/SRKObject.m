//
//  SRKObject.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/18/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import <objc/message.h>
#import <objc/objc-sync.h>
#import <objc/runtime.h>

#import "SRKObject.h"
#import "SRKObject_Private.h"
#import "SRKObjectsRamStorage.h"
#import "SRKObjectsManager.h"



NSString *const kSRKIdentifier = @"identifier";



@interface SRKObject ()
{
    NSObject *lock;
    SRKObjectsManager * _objectsManager;
    NSString * _storageName;
    
}

@property (nonnull,nonatomic,retain)NSMutableDictionary * _data;
@property (atomic)BOOL locked;


@end

@implementation SRKObject

@synthesize _data=__data;
@dynamic identifier;
@synthesize  locked=_locked;
@dynamic localId;
@dynamic objectId;




#pragma mark - constructors
#pragma mark public
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable )data{
    SRKAssert(self != [SRKObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:nil andData:data sync:YES];
    
}
+(instancetype)objectWithIdentifier:(NSString*)identifier{
    SRKAssert(self != [SRKObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:identifier andData:nil sync:YES];
}
+(instancetype)objectWithIdentifier:(NSString*)identifier andData:(NSDictionary*)data{
    SRKAssert(self != [SRKObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:identifier andData:data sync:YES];
}

+(_Nonnull instancetype)objectWithType:(NSString*)type{
    return [self objectWithType:type andIdentifier:nil andData:nil sync:NO];
}
+(instancetype)objectWithType:(NSString*)type andData:(NSDictionary*)data{
    return [self objectWithType:type andIdentifier:nil andData:data sync:YES];
}
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary *)data{
    return [self objectWithType:type andIdentifier:identifier andData:data sync:YES];
}
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier{
    return [self objectWithType:type andIdentifier:identifier andData:nil sync:YES];
}
+(instancetype)objecWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data{
    return [self objectWithType:type andIdentifier:identifier andData:data sync:YES];
}

#pragma mark private
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data sync:(BOOL)sync{
    SRKObject * obj = [[self alloc] init];
    if (type) {
        [obj setCustomStorageName:type];
    }
    for (NSString * key in data) {
        [obj setObject:[data valueForKey:key] forKey:key];
        
    }
    
    if (sync) {
        return [obj sync:NO];
    }else return obj;
}
- (instancetype)init {
    lock = [[NSObject alloc] init];
    return self;
}



#pragma mark - sync

-(instancetype)sync:(BOOL)override{
    
    if (![self allowedToUseRamStorage]) {
        return self;
    }
    SRKObject * obj = [[SRKObjectsRamStorage storageForClassName:[self _srk_objectType]] registerOrGetRecentObject:self fromStorageByIndetifier:[self identifier]];
    
    if ([obj isEqual:self]) {
        return obj;
    }
    else{
        [self copyToObject:obj override:override];
        return obj;
    }
}
-(instancetype)syncObject:(BOOL)isFetched associatedObjects:(NSArray*)objects{
    
    if ([self allowedToUseRamStorage]) {
        SRKObject * obj =  [self sync:isFetched];
        
        //getting object from ram
        
        //if object id not present means that we already sync it in temp storage
        if ([obj allowedToUseRamStorage]&&[obj objectId]) {
            NSString * storageName = [self storageName];
            
            if (storageName==nil) {
                storageName=NSStringFromClass([self class]);
            }
            NSString * name =[NSString stringWithFormat:@"%@_TEMP", storageName ];
            
            SRKObject * objectByLocalId = [[SRKObjectsRamStorage storageForClassName:name] registerOrGetRecentObject:obj fromStorageByIndetifier:obj.localId];
            if (![objectByLocalId isEqual:obj]) {
                [obj copyToObject:objectByLocalId override:isFetched];
                obj = objectByLocalId;
            }
        }
        return obj;
        
        if ([obj isEqual:self]) {
            return self;
        }
        
    }else{
        return self;
    }
    
}





#pragma mark - private methods


- (void)_setObject:(id)object forKey:(NSString *)key {
    
    id val = [self _processValue:object forKey:key];
    
    if (self.locked) {
        @synchronized (lock) {
            self._data[key]=val;
        }
    }else{
        self._data[key]=val;
    }
    
    
}

-(id)_processValue:(id)val forKey:(NSString*)key{
    
    //    [[self objectController] ]
    
    SRKProperty* prop = [[self objectsManager] propertyForKey:key];
    if (prop) {
        
        id value = val;
        
        Class propertyClass = prop.propertyClass;
        
        
        if (propertyClass == [NSString class]) {
            if ([value isKindOfClass:[NSNumber class]]) {
                // NSNumber -> NSString
                value = [value description];
            } else if ([value isKindOfClass:[NSURL class]]) {
                // NSURL -> NSString
                value = [value absoluteString];
            }
        } else if ([value isKindOfClass:[NSString class]]) { //NSString
            if (propertyClass == [NSURL class]) {
                // NSString -> NSURL
                value = [value urlFromString:val];
            } else if (prop.isNumberType) {
                NSString *oldValue = value;
                
                // NSString -> NSNumber
                if (propertyClass == [NSDecimalNumber class]) {
                    value = [NSDecimalNumber decimalNumberWithString:oldValue];
                } else {
                    value = [[SRKObject numberFormatter] numberFromString:oldValue];
                }
                
                // BOOL
                if (prop.isBoolType) {
                    
                    NSString *lower = [oldValue lowercaseString];
                    if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                        value = @YES;
                    } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                        value = @NO;
                    }
                }
            }
        } else if ([value isKindOfClass:[NSDictionary class]]&&[propertyClass isSubclassOfClass:[SRKProperty class]]){
            return [propertyClass objectWithData:value];
        }else  if (propertyClass==[NSDate class]) {
            
            if ([value isKindOfClass:[NSNumber class]]) {
                
                value = [NSDate dateWithTimeIntervalSince1970:[value integerValue]];
            } else if ([value isKindOfClass:[NSURL class]]) {
                // NSURL -> NSString
                value = nil;
            }
        }
        
        
        // duh...
        if (propertyClass && ![value isKindOfClass:propertyClass]) {
            value = nil;
        }
        
        
        return value;
        
        
    }else
        return val;
}

-(NSString *)_srk_objectType{
    NSString * storageName = [self storageName];
    
    if (storageName==nil) {
        storageName=NSStringFromClass([self class]);
    }
    if (!self.objectId) {
        return [NSString stringWithFormat:@"%@_TEMP",storageName];
    }else {
        return storageName;
    }
}

-(void)copyToObject:(SRKObject*)toObject override:(BOOL)override{
    
    [self setLocked:YES];
    if (override) {
        for (NSString * k in [self _data]) {
            toObject[k]=[self _data][k];
        }
    }else{
        //            for (NSString * k in [self _data]) {
        //                if (!obj[k]) {
        //                      obj[k]=[obj _data][k];
        //                }
        //
        //            }
    }
    
    [self setLocked:NO];
}
#pragma mark storage
-(void)setCustomStorageName:(NSString*)storageName{
    _storageName=storageName;
}
-(NSString*)storageName{
    return  _storageName;
}
-(BOOL)allowedToUseRamStorage{
    return self.identifier && (self.class != [SRKObject class] || _storageName!=nil) ;
}

#pragma mark - public



-(NSString *)localId{
    id a = self[@"localId"];
    return a;
}
-(void)setLocalId:(NSString *)localId{
    self[@"localId"]=localId;
}

-(NSString *)objectId{
    id a = self[@"objectId"];
    return a;
}
-(void)setObjectId:(NSString *)objectId{
    self[@"objectId"]=objectId;
}
-(NSString *)identifier{
    return self.objectId?self.objectId:self.localId;
}

#pragma mark static

+(void)clearRam{
    [SRKObjectsRamStorage clean];
}









#pragma mark - methods creation

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    
    if (self == [SRKObject class]) {
        return NO;
    }
    
    NSMethodSignature *signature = [[SRKObjectsManager  objectManagerForClass:[self class]] forwardingMethodSignatureForSelector:sel];
    if (!signature) {
        return NO;
    }
    
    NSMutableString *typeString = [NSMutableString stringWithFormat:@"%s", signature.methodReturnType];
    for (NSUInteger argumentIndex = 0; argumentIndex < signature.numberOfArguments; argumentIndex++) {
        [typeString appendFormat:@"%s", [signature getArgumentTypeAtIndex:argumentIndex]];
    }
    
    class_addMethod(self, sel, _objc_msgForward, typeString.UTF8String);
    
    return YES;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (![[self objectsManager] forwardObjectInvocation:anInvocation withObject:self]) {
        [self doesNotRecognizeSelector:anInvocation.selector];
    }
}

#pragma mark - lazy init
-(SRKObjectsManager*)objectsManager{
    if (!_objectsManager) {
        _objectsManager=[SRKObjectsManager objectManagerForClass:[self class]];
    }
    
    return _objectsManager;
}

static NSNumberFormatter *_numberFormatter;
+(NSNumberFormatter*)numberFormatter{
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
    }
    return _numberFormatter;
}
#pragma mark data
-(NSMutableDictionary *)_data{
    if (!__data) {
        __data=[[NSMutableDictionary alloc] init];
    }
    return __data;
}

#pragma mark - val helpers temp
- (NSURL *)urlFromString:(NSString*)string
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return [NSURL URLWithString:output];
}

@end



@implementation SRKObject(KeyValues)


#pragma mark - private

#pragma mark

-(void)removeObjectForKey:(NSString *)key{
    if (self.locked) {
        
        @synchronized (lock) {
            [self._data removeObjectForKey:key];
        }
    }else{
        [self._data removeObjectForKey:key];
    }
}
#pragma mark SETTERS

-(void)setValue:(id)value forKey:(NSString *)key{
    self[key]=key;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    self[key] = value;
}
- (void)setObject:(id)object forKey:(NSString *)key {
    
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    NSLog(@"Stack = %@", [array objectAtIndex:0]);
    NSLog(@"Framework = %@", [array objectAtIndex:1]);
    NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    
    NSString * _key = [NSString stringWithFormat:@"%C%@",
     (unichar)toupper([key characterAtIndex:0]),
                       [key substringFromIndex:1]];
    
    NSString * fullSelector = [NSString stringWithFormat:@"set%@:",_key];
    
    
//    [NSInvocation invocationWithMethodSignature:<#(nonnull NSMethodSignature *)#>]
//    
//   NSMethodSignature *  s = [NSMethodSignature methodForSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@",_key])];
//    
//    [self ]
//    
//    [self performSelector:NSSelectorFromString(fullSelector) withObject:object];
    
    [self _setObject:object forKey:key];
}





-(void)setKeyValues:(NSDictionary *)keyValues{
    for (NSString * key in keyValues) {
        [self setObject:[keyValues valueForKey:key] forKey:key];
    }
}


#pragma mark GETTERS
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
    [self setObject:object forKey:key];
}
- (id)objectForKey:(NSString *)key {
    
    if (self.locked) {
        @synchronized (lock) {
            id result = self._data[key];
            return result;
        }
    }else{
        id result = self._data[key];
        return result;
        
    }
    
}
-(id)objectForKeyedSubscript:(NSString *)key{
    return [self objectForKey:key];
}
- (id)valueForUndefinedKey:(NSString *)key {
    return self[key];
}


#pragma mark - Convert To Dictionary
-(NSDictionary *)convertToDictionary{
    
    NSMutableDictionary * newDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *currentDataCopy = [[self _data] copy];
    for (NSString * k in currentDataCopy) {
        
        id val  = [ self _data][k];
        [newDictionary setValue:[self _processForDictValue:val] forKey:k];
    }
    return newDictionary;
}
-(id)_processForDictValue:(id)val{
    if ([val isKindOfClass:[SRKObject class]]) {
        return [val convertToDictionary];
    }else if ([val isKindOfClass:[NSDictionary class]]){
        return val;
    }else if ([val isKindOfClass:[NSArray class]]){
        NSMutableArray * newArr = [[NSMutableArray alloc] init];
        
        for (id v in val) {
            [newArr addObject:[self _processForDictValue:v]];
        }
        return newArr;
    }else return val;
}

@end



@implementation SRKObject (SRKMapping)
+(SRKObjectMapping *)mappingExtends:(NSString *)extend{
    return [[SRKObjectMapping mappingExtends:extend] setMappingObjectType:[self class]];
}


+(SRKObjectMapping *)mappingWithProperties:(NSDictionary *)props{
    return [[SRKObjectMapping mappingWithProperties:props] setMappingObjectType:[self class]];
}

+(SRKObjectMapping*)mappingWithProperties:(NSDictionary *)props  indfiterKeyPath:(NSString *)indifiterKeyPath{
    return  [[SRKObjectMapping mappingWithProperties:props  indfiterKeyPath:indifiterKeyPath] setMappingObjectType:[self class]];
}


+(SRKObjectMapping *)mappingWithPropertiesArray:(NSArray *)props{
    return [[SRKObjectMapping mappingWithPropertiesArray:props] setMappingObjectType:[self class]];
}

+(SRKObjectMapping *)mappingWithPropertiesArray:(NSArray *)props indfiterKeyPath:(NSString *)indifiterKeyPath{
    return [SRKObjectMapping mappingWithPropertiesArray:props  indfiterKeyPath:indifiterKeyPath];
}

@end

