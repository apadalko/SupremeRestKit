//
//  SRKObjectMapping_Private.h
//  Pods
//
//  Created by Alex Padalko on 2/15/17.
//
//
#import "SRKObjectMapping.h"
@interface SRKObjectMapping ()
/**
 relations dictionary of mapping , saved by toKey (name of property in resulting object)
 @note if you use extend - it will use the relations of 'Super' Mapping
 */
@property (nonatomic,retain)NSMutableDictionary * relations;
/**
 properties list of mapping
 @note if you use extend - it will use the relations of 'Super' Mapping
 @note see -addMapping:withName: in `SRKMappingScope`
 */
@property (nonatomic,retain)NSDictionary * properties;

/**
 list of permanent (static) properties
 */
@property (nonatomic,retain)NSMutableDictionary * permanent;


-(NSDictionary*)dictionaryRepresentation;
@end
