//
//  SRKMappingRelation.h
//  Pods
//
//  Created by Alex Padalko on 2/15/17.
//
//

#import <Foundation/Foundation.h>
@class DSObject;


/**
 A block that validates current relation
 
 @param data               dictinary with current data.
 @param preprocessedObject current working object.
 
 @return Yes if valid to add this relation
 */
typedef BOOL (^SRKMappingRelationValidateBlock) (NSDictionary*data,DSObject * preprocessedObject);

/**
 SRKMappingRelation objects using to define relations between response data(dictionary) and nested objects. ex : {"id":"1","title":"hi","poster":{"id":"1"}} where poster is nested object type of user so relation should be as: leftKey = "poster" , rightKey = "poster" mapping = [some user mapping]
 */
@interface SRKMappingRelation : NSObject
/**
 Creates a new Mapping Relation
 
 @param fromKey    key in data.
 @param toKey      key in object(object property)
 
 @return new Mapping Relation.
 */
-(instancetype)initWithFromKey:(NSString*)fromKey toKey:(NSString*)toKey mapping:(id)mapping;

/**
 Creates a new Mapping Relation
 
 @param fromKey    key in data.
 @param toKey      key in object(object property)
 
 @return new Mapping Relation.
 */
+(instancetype)realtionWithFromKey:(NSString*)fromKey toKey:(NSString*)toKey mapping:(id)mapping;


/**
 key in data
 */
@property (nonatomic,retain)NSString * fromKey;
/**
 key in object(object property)
 */
@property (nonatomic,retain)NSString * toKey;

/**
 mapping object could be String or SRKObjectMapping
 */
@property (nonatomic,retain)id mapping;


/**
 A block that validates current relation
 @note will have more priority than statement
 */
@property (nonatomic,copy)SRKMappingRelationValidateBlock validationBlock;
/**
 String based statement to validated current relation ex:->type==1||->type==2 where "->" means reference to value in data
 @note recommended to use as [left referenced value with "->" ] [operator >,=] [logical operator]
 */
@property (nonatomic,retain)NSString * statement;


/**
 adds a validationBlock
 
 @param validationBlock     A block that validates current relation.
 
 @return current relation object.
 */
-(instancetype)addValidationBlock:(BOOL(^)(NSDictionary*data,DSObject * preprocessedObject))validationBlock;


@end
