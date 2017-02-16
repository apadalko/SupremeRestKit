//
//  SRKMappingScope.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRKObjectMapping.h"

/**
 
 below you able to see list of keys that will be used to parse dictionary of mappings
 */

/**
 ~className
 */
extern NSString *const kSRKClassName;
/**
 ~keyPath
 */
extern NSString *const kSRKKeyPath;
/**
 ~extends
 */
extern NSString *const kSRKExtend;
/**
 ~storage
 */
extern NSString *const kSRKStorageName;
/**
 ~infifiter
 */
extern NSString *const kSRKIndifiterKeyPath;


/**
 ~relations
 */
extern NSString *const kSRKRelations;
/**
 ~properties
 */
extern NSString *const kSRKProperties;
/**
 ~permanent
 */
extern NSString *const kSRKPermanent;


/**
 SRKMappingScope is used to orginize all your mappings, you able create scope with dictionary, json file or just init
 
 you may able to add new mapping as well
 
 very usefull if you are using `extends` feature of `SRKObjectMapping` object.
 ex: you able to create mapping for user with name "User", and wen u create a mapping for some Article object, just add relation with mapping that extends "User"
 
 
 */
@interface SRKMappingScope : NSObject


/**

 Default mapping scope (Singleton), use -setDataDictionary:,-setDataFromFile: or -addMapping:forName: to custumize mappings for default scope
 used by default (in scope not provided) in `SRKObjectMapper` and `SRKClient`
 
 @return default Mapping scope
 @note default mapping scope used by default (if scope not provided) in `SRKObjectMapper` and `SRKClient`
 */
+(instancetype)defaultScope;


/**
 Creates a new Mapping Scope, with empty mappings data
 
 @return new Mapping Scope
 */
-(instancetype)init;

/**
 Creates a new Mapping Scope from .json file
 @param fileName    .json file with valid SRKMapping json data
 @return new Mapping Scope
 
 @note use keys above to generate a valid json file for mapping
 */
-(instancetype)initWithFile:(NSString*)fileName;

/**
 Creates a new Mapping Scope from .json file
 @param data    valid-formatted dictionary for mapping
 @return new Mapping Scope
 
 @note use keys above to generate a valid dictionary for mapping
 */
-(instancetype)initWithDictionary:(NSDictionary*)data;


/**
 sets the mapping data from dictionary
 @param data    valid-formatted dictionary for mapping
 
 @note use keys above to generate a valid dictionary for mapping
 */
-(void)setDataDictionary:(NSDictionary*)data;


/**
 @param fileName    .json file with valid SRKMapping json data
 
 @note use keys above to generate a valid json file for mapping
 */
-(void)setDataFromFile:(NSString*)fileName;



/**
 add a mapping for name, you will able to extend another mapping (`SRKObjectMapping`) using this name
 @param mapping    valid `SRKObjectMapping`
 @pramr name    name of the mapping in memory, you able to extend a new mapping by thi name
 @return current Mapping Scope
 */
-(instancetype)addMapping:(SRKObjectMapping*)mapping forName:(NSString*)name;


/**
 returns all mappings referenced by mapping object
 @param mapping    mapping it can be: `SRKObjectMapping`, Array<SRKObjectMapping>, String, Array<String>, Dictionary
 @return current Mapping Scope
 */
-(NSArray<SRKObjectMapping*>*)getObjectMappings:(id)mapping;
@end

