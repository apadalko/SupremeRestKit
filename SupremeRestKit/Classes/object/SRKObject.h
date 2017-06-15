//
//  SRKObject.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/18/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRKObjectMapping.h"

/**
 identifier
 */

#ifndef SRKAssert
#define SRKAssert( condition, ... ) NSCAssert( (condition) , ##__VA_ARGS__)
#endif // DSAssert



NS_REQUIRES_PROPERTY_DEFINITIONS

@interface SRKObject : NSObject

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

+(_Nonnull instancetype)objectWithType:(NSString*)type;
+(_Nonnull instancetype)objectWithType:(NSString*)type andData:(NSDictionary* _Nullable )data;
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier;
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data;

+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable )data;
+(instancetype)objectWithIdentifier:(NSString*)identifier;
+(instancetype)objectWithIdentifier:(NSString*)identifier andData:(NSDictionary*)data;






@property (nonatomic,retain)NSString * objectId;
@property (nonatomic,retain)NSString * localId;








-(instancetype)sync:(BOOL)override;


////
+(void)clearRam;

-(void)copyToObject:(SRKObject*)toObject override:(BOOL)override;
@end


@interface SRKObject (KeyValues)
-(void)setKeyValues:(NSDictionary * _Nullable)keyValues;


#pragma mark - set objs
- (nullable id)objectForKey:( NSString * _Nonnull)key;
- (void)setObject:(id _Nullable)object forKey:(NSString * _Nullable)key;
- (void)removeObjectForKey:(NSString * _Nonnull)key;

//TODO make able to use properties here
- (nullable id)objectForKeyedSubscript:(NSString * _Nonnull)key;
- (void)setObject:(id _Nullable)object forKeyedSubscript:(NSString * _Nullable)key;


-(NSDictionary* _Nonnull)convertToDictionary;


@end

@interface SRKObject (Observing)

//-(void)observeProperty:(NSString*)propertyName with
@end



/**
 usefull extension of SRKObject that allow to easy create a mapping for related object class
 */
@interface SRKObject (SRKMapping)

/**
 Creates a new Object Mapping from specific class
 
 
 @return new Mapping Object ready for mapping.

 @warning availavle only for subclasses
 */
+(SRKObjectMapping*)mapping;




@end

