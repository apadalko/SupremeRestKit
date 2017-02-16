//
//  SRKObjectMapping.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "SRKMappingRelation.h"



/**
 SRKObjectMapping objects using to map dictionary to given object `DSObject`
 
 you able to create mapping objects in two ways:
 
 i.  create Mapping with properties from array/dictionary
 ii. as Mapping that extends other mapping. In this case you need to provide mapping name that already in a current mapping scope, or will be there before request (see -addMapping:withName: in `SRKMappingScope`)
 
 Couple things that you should knew:
 
 - !!! if you want that object will be unique you need to add maping for objectId property which is basic for any `DSObject` subclass and DSObject itself
 
 - if you want to map to the specific object class you should specify a className property
 - if you doesnt want to create a class but wanna still have a unique object specify storageName to make sure object will be saved in specific storage
 

 - You also able to map objectId using objectIdentifierKeyPath ex:{"title","...","id":1} in this case all what you need to do is to set objectIdentifierKeyPath = "id"
 - you able to provide keyPath for a specific mapping in data ex: {"title","...","user":{"id","1","name":"alex","address":{"city":"New York"}}} , keypath for address is "user.address"
 - in case if u need to provide permanent (static) properties you able to use -addPermanentProperty


 
 @note all objects WITH MAPPED OBJECTID OR SPECIFIED objectIdentifierKeyPath will be saved in memmory and autoreleased when specific object will not have any strong pointers to it
 @note
 */
@interface SRKObjectMapping : NSObject


#pragma mark - constructors
/**
 Creates a new Object Mapping with propeties listed in array , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props    properties listed in Array.
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note you able to rename properies by using arrow symbol "->" ex : @["id->objectId","name->username","bio","age","full_name->fullName"]
 
 @return new Mapping Object ready for mapping.
 */
+(instancetype)mappingWithPropertiesArray:(NSArray*)props;
/**
 Creates a new Object Mapping with propeties listed in array by specific key path , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props     properties listed in Array.
 @param keyPath   key path in data (Dictionary) where resulting object should take data
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note you able to rename properies by using arrow symbol "->" ex : @["id->objectId","name->username","bio","age","full_name->fullName"]
 
 @return new Mapping Object ready for mapping.
 */
+(instancetype)mappingWithPropertiesArray:(NSArray*)props andKeyPath:(NSString*)keyPath;

/**
 Creates a new Object Mapping with propeties listed in array by specific key path and indifiter , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props     properties listed in Array.
 @param keyPath   key path in data (Dictionary) where resulting object should take data
 @param indifiterKeyPath   using to map objectId from given data
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note you able to rename properies by using arrow symbol "->" ex : @["id->objectId","name->username","bio","age","full_name->fullName"]
 @note use this initialized if u didn't plan to map objectId in propertiesArray
 
 @return new Mapping Object ready for mapping.
 */
+(instancetype)mappingWithPropertiesArray:(NSArray*)props andKeyPath:(NSString*)keyPath indfiterKeyPath:(NSString*)indifiterKeyPath;;

/**
 Creates a new Object Mapping with properties listed in dictionary {"K":"V"} where K is key in given data and V is property name in resulting object `DSObject`
 
 @param props    properties in Dictionary. Key is value in given data, Value is name of the property in resulting object for ex {"full_name":"lala","id":"222"} so the properties dictionaty will look like this {"full_name":"fullName","id":"objectId"}
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 
 @return new Mapping Object ready for mapping.
 */
+(instancetype)mappingWithProperties:(NSDictionary*)props;

/**
 Creates a new Object Mapping with properties listed in dictionary ( {"K":"V"} where K is key in given data and V is property name in resulting object `DSObject`)  by specific key path
 
 @param props    properties in Dictionary. Key is value in given data, Value is name of the property in resulting object for ex {"full_name":"lala","id":"222"} so the properties dictionaty will look like this {"full_name":"fullName","id":"objectId"}
 @param keyPath   key path in data (Dictionary) where resulting object should take data

 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 
 @return new Mapping Object ready for mapping.
 */
+(instancetype)mappingWithProperties:(NSDictionary*)props andKeyPath:(NSString*)keyPath;
/**
 Creates a new Object Mapping with properties listed in dictionary ( {"K":"V"} where K is key in given data and V is property name in resulting object `DSObject`)  by specific key path and indifiter key
 
 @param props    properties in Dictionary. Key is value in given data, Value is name of the property in resulting object for ex {"full_name":"lala","id":"222"} so the properties dictionaty will look like this {"full_name":"fullName","id":"objectId"}
 @param keyPath   key path in data (Dictionary) where resulting object should take data
 @param indifiterKeyPath   using to map objectId from given data
 
 @note all listed properties may be served as keypathes. Just use stadart "." syntax as "post.fromUser"
 @note use this initialized if u didn't plan to map objectId in properties dictionary
 
 @return new Mapping Object ready for mapping.
 */
+(instancetype)mappingWithProperties:(NSDictionary*)props andKeyPath:(NSString*)keyPath indfiterKeyPath:(NSString*)indifiterKeyPath;

/**
 Creates a new Object Mapping extended form another mapping in a current Mapping Scope
 
 @param extend    name of another the mapping in a current mapping scope

 @return new Mapping Object ready for mapping.
 
 @note all properties would be extended from 'Super' Mapping
 @note see -addMapping:withName: in `SRKMappingScope`
 */
+(instancetype)mappingExtends:(NSString*)extend;



#pragma mark - properties


/**
 name of the class of resulting object, make sure that class Exsits
 @note if you use extend - it will use the className of 'Super' Mapping
 */
@property (nonatomic,retain)NSString * className;

/**
 key path in data (Dictionary) where resulting object should take data
 @note if you use extend - it will use the keyPath of 'Super' Mapping
 */
@property (nonatomic,retain)NSString * keyPath;




/**
 name of the extended mapping
 
 */
@property (nonatomic,retain)NSString * extends;


///////////////////
//@property (nonatomic)BOOL fetched;
///////////////////


/**
 name of the storage where give object will be saved
 @note by default `DSObject` will use name of the class
 */
@property (nonatomic,retain)NSString * storageName;

/**
 key path for object indentifier , use this if you not planing to map objectId properties
 */
@property (nonatomic,retain)NSString * objectIdentifierKeyPath;



#pragma mark - comfortable accessores


/**
 set the properties from array and returns current Mapping Object , u able to rename them by using arrow "->" ex @[@"full_name->fullName",...]
 
 @param props    properties listed in Array.
 
 @return current Mapping Object.
 
 */
-(instancetype)setPropertiesFromArray:(NSArray*)props;
/**
 set the properties listed in dictionary ( {"K":"V"} where K is key in given data and V is property name in resulting object `DSObject`)  by specific key path and indifiter key
 
 @param props    properties in dictionary.
 
 @return current Mapping Object.
 */
-(instancetype)setPropertiesFromDictionary:(NSDictionary*)props;


/**
 set the objectIdentifierKeyPath and returns current Mapping Object
 
 @param keyPath    objectIdentifierKeyPath.
 
 @return current Mapping Object.
 @note use this if you not planing to map objectId properties
 
 */
-(instancetype)addObjectIdentifierKeyPath:(NSString*)keyPath;

/**
 set the custom storage Name, usefull when you doesnt have a physicall class of objects
 
 @param storageName    name of the storage in memory.
 
 @return current Mapping Object.
 @note use this if you do not specify className and still wanna have unique object in storage
 
 */
-(instancetype)addStorageName:(NSString*)storageName;

/**
 add a new realtion to mapping
 
 @param fromKey           key in given data, can be nil
 @param toKey             name of property in resulting object , relations will be stored by this key (name of property in resulting object)
 @param relationMapping   mapping of this nested object (`SRKObjectMapping`)
 @note relation are saved by toKey - name of property in resulting object
 @return current Mapping Object.
 
 */
-(instancetype)addRelation:(NSString*)fromKey toKey:(NSString*)toKey relationMapping:(SRKObjectMapping*)relationMapping;

/**
 add a new realtion to mapping
 
 @param relation   relation object `SRKMappingRelation`
 
 @return current Mapping Object.
 @note relation are saved by toKey - name of property in resulting object
 */
-(instancetype)addRelation:(SRKMappingRelation*)relation;
/**
 add a permanent (static) property
 
 @param key    name of the property in resulting object
 @param value   value of this property
 
 @return current Mapping Object.
 */
-(instancetype)addPermanentProperty:(NSString*)key value:(id)value;

/**
 sets the key path in data (Dictionary) where resulting object should take data
 
 @param keyPath    key path in data (Dictionary) where resulting object should take data
 
 @return current Mapping Object.
 */
-(instancetype)addKeyPath:(NSString*)keyPath;
@end
