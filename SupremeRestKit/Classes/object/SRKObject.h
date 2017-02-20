//
//  SRKObject.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/18/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import <DSObject/DSObject.h>
#import "SRKObjectMapping.h"
@interface SRKObject : DSObject

@property (nonatomic,retain)NSString * objectId;
@property (nonatomic,retain)NSString * localId;


@end


/**
 usfull extention of SRKObject that allow to easy create a mapping for related object class
 */
@interface SRKObject (SRKMapping)
/**
 Creates a new Object Mapping with propeties listed in array , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props    properties listed in Array.
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note you able to rename properies by using arrow symbol "->" ex : @["id->objectId","name->username","bio","age","full_name->fullName"]
 
 @return new Mapping Object ready for mapping.
 */
+(instancetype)mappingWithPropertiesArray:(NSArray*)props;


/**
 Creates a new Object Mapping with propeties listed in array by specific key path and indifiter , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props     properties listed in Array.
 @param indifiterKeyPath   using to map objectId from given data
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note you able to rename properies by using arrow symbol "->" ex : @["id->objectId","name->username","bio","age","full_name->fullName"]
 @note use this initialized if u didn't plan to map objectId in propertiesArray
 
 @return new Mapping Object ready for mapping.
 */
+(SRKObjectMapping *)mappingWithPropertiesArray:(NSArray*)props indfiterKeyPath:(NSString*)indifiterKeyPath;;

/**
 Creates a new Object Mapping with properties listed in dictionary {"K":"V"} where K is key in given data and V is property name in resulting object `SRKObject`
 
 @param props    properties in Dictionary. Key is value in given data, Value is name of the property in resulting object for ex {"full_name":"lala","id":"222"} so the properties dictionaty will look like this {"full_name":"fullName","id":"objectId"}
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 
 @return new Mapping Object ready for mapping.
 */
+(SRKObjectMapping *)mappingWithProperties:(NSDictionary*)props;


/**
 Creates a new Object Mapping with properties listed in dictionary ( {"K":"V"} where K is key in given data and V is property name in resulting object `SRKObject`)  with indifiter key
 
 @param props    properties in Dictionary. Key is value in given data, Value is name of the property in resulting object for ex {"full_name":"lala","id":"222"} so the properties dictionaty will look like this {"full_name":"fullName","id":"objectId"}
 @param indifiterKeyPath   using to map objectId from given data
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note use this initialized if u didn't plan to map objectId in properties dictionary
 
 @return new Mapping Object ready for mapping.
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

