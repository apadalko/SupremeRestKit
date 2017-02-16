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
 Creates a new Mapping Scope, with empty mappings data
 
 @return new Mapping Scope
 */
-(instancetype)init;

/**
 Creates a new Mapping Scope from .json file
 @return new Mapping Scope
 
 @note 
 */
-(instancetype)initWithFile:(NSString*)filepath;
-(instancetype)initWithDictionary:(NSDictionary*)data;

-(instancetype)addMapping:(SRKObjectMapping*)mapping forName:(NSString*)name;

-(NSArray<SRKObjectMapping*>*)getObjectMappings:(id)mapping;
@end

