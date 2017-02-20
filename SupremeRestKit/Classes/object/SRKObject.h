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


/**
 usfull extension of SRKObject that allow to easy create a mapping for related object class
 */
@interface SRKObject (SRKMapping)
/**
 Creates a new Object Mapping with propeties listed in array , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props    properties listed in Array.
 
 @return new Mapping Object ready for mapping.
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note you able to rename properies by using arrow symbol "->" ex : @["id->objectId","name->username","bio","age","full_name->fullName"]
 */
+(instancetype)mappingWithPropertiesArray:(NSArray*)props;


/**
 Creates a new Object Mapping with propeties listed in array by specific key path and indifiter , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props     properties listed in Array.
 @param indifiterKeyPath   using to map objectId from given data
 
 @return new Mapping Object ready for mapping.
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note you able to rename properies by using arrow symbol "->" ex : @["id->objectId","name->username","bio","age","full_name->fullName"]
 @note use this initialized if u didn't plan to map objectId in propertiesArray
 */
+(SRKObjectMapping *)mappingWithPropertiesArray:(NSArray*)props indfiterKeyPath:(NSString*)indifiterKeyPath;;

/**
 Creates a new Object Mapping with properties listed in dictionary {"K":"V"} where K is key in given data and V is property name in resulting object `SRKObject`
 
 @param props    properties in Dictionary. Key is value in given data, Value is name of the property in resulting object for ex {"full_name":"lala","id":"222"} so the properties dictionaty will look like this {"full_name":"fullName","id":"objectId"}
 
 @return new Mapping Object ready for mapping.
 
  @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 */
+(SRKObjectMapping *)mappingWithProperties:(NSDictionary*)props;


/**
 Creates a new Object Mapping with properties listed in dictionary ( {"K":"V"} where K is key in given data and V is property name in resulting object `SRKObject`)  with indifiter key
 
 @param props    properties in Dictionary. Key is value in given data, Value is name of the property in resulting object for ex {"full_name":"lala","id":"222"} so the properties dictionaty will look like this {"full_name":"fullName","id":"objectId"}
 @param indifiterKeyPath   using to map objectId from given data
 
 @return new Mapping Object ready for mapping.
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note use this initialized if u didn't plan to map objectId in properties dictionary
 */
+(SRKObjectMapping *)mappingWithProperties:(NSDictionary*)props  indfiterKeyPath:(NSString*)indifiterKeyPath;

/**
 Creates a new Object Mapping extended form another mapping in a current Mapping Scope
 
 @param extend    name of another the mapping in a current mapping scope
 
 @return new Mapping Object ready for mapping.
 
 @note all properties would be extended from 'Super' Mapping
 @note see -addMapping:withName: in `SRKMappingScope`
 */
+(SRKObjectMapping *)mappingExtends:(NSString*)extend;


@end

