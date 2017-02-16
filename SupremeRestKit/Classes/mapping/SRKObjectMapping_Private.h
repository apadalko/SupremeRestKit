//
//  SRKObjectMapping_Private.h
//  Pods
//
//  Created by Alex Padalko on 2/15/17.
//
//

@interface SRKObjectMapping ()
/**
 relations list of mapping
 @note if you use extend - it will use the relations of 'Super' Mapping
 */
@property (nonatomic,retain)NSMutableArray<SRKMappingRelation *> * relations;
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
@end
