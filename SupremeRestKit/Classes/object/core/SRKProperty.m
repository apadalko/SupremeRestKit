//
//  SRKProperty.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/14/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKProperty.h"
#import <objc/message.h>

/// some constanst to finds out type of object
NSString *const SRKPropertyTypeInt = @"i";
NSString *const SRKPropertyTypeShort = @"s";
NSString *const SRKPropertyTypeFloat = @"f";
NSString *const SRKPropertyTypeDouble = @"d";
NSString *const SRKPropertyTypeLong = @"l";
NSString *const SRKPropertyTypeLongLong = @"q";
NSString *const SRKPropertyTypeChar = @"c";
NSString *const SRKPropertyTypeBOOL1 = @"c";
NSString *const SRKPropertyTypeBOOL2 = @"b";
NSString *const SRKPropertyTypePointer = @"*";

NSString *const SRKPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const SRKPropertyTypeMethod = @"^{objc_method=}";
NSString *const SRKPropertyTypeBlock = @"@?";
NSString *const SRKPropertyTypeClass = @"#";
NSString *const SRKPropertyTypeSEL = @":";
NSString *const SRKPropertyTypeId = @"@";




static inline NSString *srk_safeStringWithPropertyAttributeValue(objc_property_t property, const char *attribute) {
    char *value = property_copyAttributeValue(property, attribute);
    if (!value)
        return nil;
        return (__bridge_transfer NSString *)CFStringCreateWithCStringNoCopy(NULL,
                                                                         value,
                                                                         kCFStringEncodingUTF8,
                                                                         kCFAllocatorMalloc);
}

static inline NSString *srk_stringByCapitalizingFirstCharacter(NSString *string) {
    return [NSString stringWithFormat:@"%C%@",
            (unichar)toupper([string characterAtIndex:0]),
            [string substringFromIndex:1]];
}



@implementation SRKProperty
static NSArray  * _numberTypes;

+(NSArray*)numberTypes {
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       _numberTypes =  @[SRKPropertyTypeInt, SRKPropertyTypeShort, SRKPropertyTypeBOOL1, SRKPropertyTypeBOOL2, SRKPropertyTypeFloat, SRKPropertyTypeDouble, SRKPropertyTypeLong, SRKPropertyTypeLongLong, SRKPropertyTypeChar];
    });
    return _numberTypes;
};

+ (instancetype)propertyWithSourceClass:(Class)sourceClass andName:(NSString *)propertyName;
{
    return [[self alloc] initWithSourceClass:sourceClass name:propertyName];
}


- (instancetype)initWithSourceClass:(Class)sourceClass name:(NSString *)propertyName {
    self = [super init];
    if (!self) return nil;
    
    _sourceClass = sourceClass;
    _propertyName = [propertyName copy];
//    _associationType = associationType;
    
    objc_property_t objcProperty = class_getProperty(sourceClass, _propertyName.UTF8String);
    
    _typeEncoding = srk_safeStringWithPropertyAttributeValue(objcProperty, "T");
    _objectType = [_typeEncoding hasPrefix:@"@"];
    
    NSString *propertyGetter = srk_safeStringWithPropertyAttributeValue(objcProperty, "G") ?: _propertyName;
    _getterSelector = NSSelectorFromString(propertyGetter);
    
    BOOL readonly = srk_safeStringWithPropertyAttributeValue(objcProperty, "R") != nil;
    NSString *propertySetter = srk_safeStringWithPropertyAttributeValue(objcProperty, "S");
    if (propertySetter == nil && !readonly) {
        propertySetter = [NSString stringWithFormat:@"set%@:", srk_stringByCapitalizingFirstCharacter(_propertyName)];
    }
    
    _setterSelector = NSSelectorFromString(propertySetter);
    

    BOOL isCopy = srk_safeStringWithPropertyAttributeValue(objcProperty, "C") != nil;
    BOOL isWeak = srk_safeStringWithPropertyAttributeValue(objcProperty, "W") != nil;
    BOOL isRetain = srk_safeStringWithPropertyAttributeValue(objcProperty, "&") != nil;
    
    if (isWeak) {
        _propertyForceType = SRKPropertyForceTypeWeak;
    } else if (isCopy) {
        _propertyForceType = SRKPropertyForceTypeCopy;
    } else if (isRetain) {
        _propertyForceType = SRKPropertyForceTypeStrong;
    } else {
        _propertyForceType = SRKPropertyForceTypeAssign;
    }
    
    NSString *attrs = @(property_getAttributes(objcProperty));
    NSUInteger dotLoc = [attrs rangeOfString:@","].location;
    NSString *code = nil;
    NSUInteger loc = 1;
    if (dotLoc == NSNotFound) {
        code = [attrs substringFromIndex:loc];
    } else {
        code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
    }
    _code = code;
 
    
    if ([_code isEqualToString:SRKPropertyTypeId]) {
        _objectType = YES;
    } else if (code.length == 0) {
        //blabla 
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        _propertyClassName = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _propertyClass = NSClassFromString(_propertyClassName);
        //TODO FOUNDATION CHECK??
        
        _numberType = [_propertyClass isSubclassOfClass:[NSNumber class]];
        
    } else if ([code isEqualToString:SRKPropertyTypeSEL] ||
               [code isEqualToString:SRKPropertyTypeIvar] ||
               [code isEqualToString:SRKPropertyTypeMethod]) {
        
// THIS THIS NOT A PROP
//
    }

    NSString *lowerCode = _code.lowercaseString;
 
    if ([[SRKProperty numberTypes] containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:SRKPropertyTypeBOOL1]
            || [lowerCode isEqualToString:SRKPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }

    
    
    
    return self;
}


@end
