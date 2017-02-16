//
//  SRKMappingRelation_Private.h
//  Pods
//
//  Created by Alex Padalko on 2/16/17.
//
//
#import "SRKMappingRelation.h"

/**
 SRKMappingRelation object, this is private fie, mostly used for while generating mapping from file
 */
@interface SRKMappingRelation (Private)

+(instancetype)relationWithComplexKey:(NSString*)complexKey;


@end
