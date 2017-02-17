//
//  SRKObjectMapping.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKObjectMapping.h"
#import "SRKObjectMapping_Private.h"
#import "SRKMappingRelation_Private.h"
//need it for keys
#import "SRKMappingScope.h"
@interface SRKObjectMapping ()

@end
@implementation SRKObjectMapping

+(instancetype)mappingExtends:(NSString *)extend{
    SRKObjectMapping * mapping = [[SRKObjectMapping alloc] init];
    [mapping setExtends:extend];
    
    return mapping;
}
-(instancetype)init{
    if (self=[super init]) {
//        self.fetched=YES;
    }
    return self;
}
+(instancetype)mappingWithPropertiesArray:(NSArray*)props{
    return  [self mappingWithPropertiesArray:props andKeyPath:nil indfiterKeyPath:nil];
}

+(instancetype)mappingWithPropertiesArray:(NSArray*)props andKeyPath:(NSString *)keyPath{
    return  [self mappingWithPropertiesArray:props andKeyPath:keyPath indfiterKeyPath:nil];
}
+(instancetype)mappingWithPropertiesArray:(NSArray *)props andKeyPath:(NSString *)keyPath indfiterKeyPath:(NSString *)indifiterKeyPath{
    
    NSMutableDictionary * propsDict = [[NSMutableDictionary alloc] init];
    for (NSString * k in props) {
        NSArray * arr = [k componentsSeparatedByString:@"->"];
        [propsDict setValue:[arr lastObject] forKey:[arr firstObject]];
    }
    return [self mappingWithProperties:propsDict andKeyPath:keyPath indfiterKeyPath:indifiterKeyPath];
}

+(instancetype)mappingWithProperties:(NSDictionary*)props{
    return [self mappingWithProperties:props andKeyPath:nil];
}
+(instancetype)mappingWithProperties:(NSDictionary *)props andKeyPath:(NSString *)keyPath{
    return [self mappingWithProperties:props andKeyPath:keyPath indfiterKeyPath:nil];
}
+(instancetype)mappingWithProperties:(NSDictionary*)props andKeyPath:(NSString*)keyPath indfiterKeyPath:(NSString*)indifiterKeyPath{
    SRKObjectMapping * mapping = [[SRKObjectMapping alloc] init];
    mapping.keyPath=keyPath;
    mapping.objectIdentifierKeyPath=indifiterKeyPath;
    NSMutableDictionary * propsDict = [[NSMutableDictionary alloc] init];
    
    for (NSString * k in props) {
        [propsDict setValue:[props valueForKey:k] forKey:k];
    }
    mapping.properties=propsDict;
    return mapping;
}


-(instancetype)setPropertiesFromArray:(NSArray*)props{
    NSMutableDictionary * propsDict = [[NSMutableDictionary alloc] init];
    for (NSString * k in props) {
        NSArray * arr = [k componentsSeparatedByString:@"->"];
        [propsDict setValue:[arr lastObject] forKey:[arr firstObject]];
    }
    return  [self setPropertiesFromDictionary:propsDict];
}
-(instancetype)setPropertiesFromDictionary:(NSDictionary*)props{
    NSMutableDictionary * propsDict = [[NSMutableDictionary alloc] init];
    for (NSString * k in props) {
        [propsDict setValue:[props valueForKey:k] forKey:k];
    }
    self.properties=propsDict;
}


-(instancetype)addRelation:(SRKMappingRelation*)relation{
    if (!_relations) {
        _relations=[[NSMutableDictionary alloc] init];
    }
    [_relations setValue:relation  forKey:relation.toKey];
    return self;
}

-(instancetype)addRelation:(NSString*)fromKey toKey:(NSString*)toKey relationMapping:(SRKObjectMapping*)relationMapping{
    return [self addRelation:[SRKMappingRelation realtionWithFromKey:fromKey toKey:toKey mapping:relationMapping]];
    
}
-(instancetype)addObjectIdentifierKeyPath:(NSString *)keyPath{
    self.objectIdentifierKeyPath=keyPath;
    return  self;
}
-(instancetype)addKeyPath:(NSString *)keyPath{
    self.keyPath=keyPath;
    return self;
}
-(instancetype)addPermanentProperty:(NSString*)key value:(id)value{
    if (!_permanent) {
        _permanent=[[NSMutableDictionary alloc] init];
    }
    [_permanent setValue:value forKey:key];
    return self;
}

-(instancetype)addStorageName:(NSString *)storageName{
    self.storageName=storageName;
    return self;
}


-(NSDictionary*)dictionaryRepresentation{
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setValue:self.className forKey:kSRKClassName];
    [dictionary setValue:self.extends forKey:kSRKExtend];
    [dictionary setValue:self.storageName forKey:kSRKStorageName];
    [dictionary setValue:self.keyPath forKey:kSRKKeyPath];
    [dictionary setValue:self.objectIdentifierKeyPath forKey:kSRKIndifiterKeyPath];
    [dictionary setValue:self.permanent forKey:kSRKPermanent];
    [dictionary setValue:self.properties forKey:kSRKProperties];
    
    NSMutableDictionary * relationsRepresentation = [[NSMutableDictionary alloc] init];
    for (NSString * key in self.relations) {
        SRKMappingRelation * relation = [self.relations valueForKey:key];
        
        NSString * complexKey;
        
        if (relation.fromKey == nil) {
            complexKey=[NSString stringWithFormat:@"->%@",relation.toKey];
        }else {
            complexKey=[NSString stringWithFormat:@"%@->%@",relation.fromKey,relation.toKey];

        }
        
        [relationsRepresentation setValue:relation forKey:complexKey];
    }
    [dictionary setValue:relationsRepresentation forKey:kSRKRelations];
    
    return dictionary;
}

@end
