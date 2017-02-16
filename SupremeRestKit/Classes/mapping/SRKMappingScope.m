//
//  SRKMappingScope.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKMappingScope.h"
#import "SRKObjectMapping_Private.h"
#import "SRKMappingRelation_Private.h"


NSString *const kSRKClassName = @"~className";
NSString *const kSRKKeyPath = @"~keyPath";
NSString *const kSRKExtend = @"~extends";
NSString *const kSRKStorageName = @"~storage";
NSString *const kSRKIndifiterKeyPath = @"~infifiter";
NSString *const kSRKRelations = @"~relations";
NSString *const kSRKProperties = @"~properties";
NSString *const kSRKPermanent = @"~permanent";


@interface SRKMappingScope ()

@property (nonatomic,retain)NSMutableDictionary * mappingData;
@property (nonatomic,retain)NSMutableDictionary * processedMappings;



@end
@implementation SRKMappingScope
-(instancetype)initWithFile:(NSString*)filepath{
    
    
    NSData * d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[filepath stringByReplacingOccurrencesOfString:@".json" withString:@""] ofType:@"json"]];
    NSDictionary * dict =   [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
    return [self initWithDictionary:dict];
}
-(instancetype)initWithDictionary:(NSDictionary*)data{
    if (self=[super init]) {
        self.processedMappings = [[NSMutableDictionary alloc] init];
        self.mappingData=[[NSMutableDictionary alloc] initWithDictionary:data];
    }
    return self;
}
-(instancetype)init{
    return  [self initWithDictionary:@{}];
}
-(NSArray<SRKObjectMapping*>*)getObjectMappings:(id)mapping{
    
    
    if ([mapping isKindOfClass:[NSArray class]]) {
        
        NSMutableArray * result = [[NSMutableArray alloc] init];
        for (id obj in mapping) {
            SRKObjectMapping * m = [self _getObjectMapping:obj];
            if (m) {
                [result addObject:m];
            }
        }
        return result;
    }else{
        SRKObjectMapping * m = [self _getObjectMapping:mapping];
        if (m) {
            return @[m];
        }else{
            return @[];
        }
    }
    
    
}

-(SRKObjectMapping*)_getObjectMapping:(id)mapping{
    
    
    if ([mapping isKindOfClass:[NSString class]]) {
        id data = [self.processedMappings valueForKey:mapping];
        if (data) {
            return  data;
        }else{
            id data = [self.mappingData valueForKey:mapping];
            SRKObjectMapping * objectMapping = [self _getObjectMapping:data];
            if (objectMapping) {
                [self.processedMappings setValue:objectMapping forKey:mapping];
            }
            return objectMapping;
        }
    }else if ([mapping isKindOfClass:[NSDictionary class]]){
        SRKObjectMapping * objectMapping = [self _generateMappingFromDictionary:mapping];
        return objectMapping;
    }else if ([mapping isKindOfClass:[SRKObjectMapping class]]){
        
        SRKObjectMapping * mappingObject = mapping;
        //so in this case we will generate dictionary representation of mapping and will  and will treat it like any other mapping which generated from dictionary
        
        mappingObject = [self _generateMappingFromDictionary:[mappingObject dictionaryRepresentation]];

        return mappingObject;
    }else return nil;
}

//-(id)valueForUndefinedKey:(NSString *)key{
//    
//    if ([key isEqualToString:@"extends"]) {
//        NSLog(@">>>");
//    }
//    
//    return  nil;
//}

-(instancetype)addMapping:(SRKObjectMapping *)mapping forName:(NSString *)name{
    [self.mappingData setValue:mapping forKey:name];
}


-(SRKObjectMapping*)_generateMappingFromDictionary:(NSDictionary*)dictionary{
    
    //1 get all current data properties
    NSString * className = [[dictionary valueForKey:kSRKClassName] copy];
    NSString * extends = [[dictionary valueForKey:kSRKExtend] copy];
    NSString * storageName = [[dictionary valueForKey:kSRKStorageName] copy];
    NSString * keyPath = [[dictionary valueForKey:kSRKKeyPath] copy];
    NSString * identifierKeyPath = [[dictionary valueForKey:kSRKIndifiterKeyPath] copy];
    
    NSDictionary * _permanent = [dictionary valueForKey:kSRKPermanent];
    NSDictionary * _properties = [dictionary valueForKey:kSRKProperties];
    NSDictionary * _relations = [dictionary valueForKey:kSRKRelations];
    
    if (!className&&!extends&&!identifierKeyPath&&!_properties&&!_relations) {
        
        return (SRKObjectMapping*)dictionary;
    }
    // creating copy of properties
    NSMutableDictionary * properties = [[NSMutableDictionary alloc] initWithDictionary:_properties];
    if (!properties) {
        properties=[[NSMutableDictionary alloc] init];
    }
    //generating empty dictionary for relations
    NSMutableDictionary * processedRelations = [[NSMutableDictionary alloc] init];
    //generating empty dictionary for permanent properties
    NSMutableDictionary * permanentProperties = [[NSMutableDictionary alloc] init];

    // if object extends other object we will load extended object properties,relations,and permanent values
    if (extends) {
        //loading object
        SRKObjectMapping * extendedMapping = [self _getObjectMapping:extends];
        if (extendedMapping){ // there is a chance that object doesnt exsits
            //copy properties
            [properties setValuesForKeysWithDictionary:[extendedMapping properties]];
            //copy relations objects
            [processedRelations setValuesForKeysWithDictionary:[extendedMapping relations]];
            //copy permanent props
            [permanentProperties setValuesForKeysWithDictionary:[extendedMapping permanent]];
            
            // replace other properties if they are nil
            if (!className) {
                className=[extendedMapping className];
            }
            if (!storageName) {
                storageName = [extendedMapping storageName];
            }
            if (!keyPath) {
                keyPath = [extendedMapping keyPath];
            }
            if (!identifierKeyPath) {
                identifierKeyPath=[extendedMapping objectIdentifierKeyPath];
            }
        }
     
    }
    //process relations
    
    
    
    for (NSString * relationComplexKey in _relations) {
        
        
        id data = [_relations valueForKey:relationComplexKey];
        
        if ([data isKindOfClass:[SRKMappingRelation class]]){
            SRKMappingRelation * relation = data;
            SRKObjectMapping * mapping = [self _getObjectMapping:relation.mapping];
            if (mapping){
                SRKMappingRelation * newRelation = [SRKMappingRelation realtionWithFromKey:relation.fromKey toKey:relation.toKey mapping:mapping];
                newRelation.validationBlock = relation.validationBlock;
                [processedRelations setValue:newRelation forKey:relation.toKey];

            }
        }
        else
        if ([relationComplexKey hasPrefix:@"?"]) {
            
            NSMutableDictionary * statementMapping = [[NSMutableDictionary alloc] init];
            id subRelations  = data;
            for (NSString * subRelationComplexKey in subRelations) {
                
                SRKMappingRelation * relation = [SRKMappingRelation relationWithComplexKey:subRelationComplexKey];
                if (relation) {
                    SRKObjectMapping * subRelationMapping = [self _getObjectMapping:[subRelations valueForKey:subRelationComplexKey]];
                    if (subRelationMapping) {
                        relation.mapping = subRelationMapping;
                        [statementMapping setValue:relation forKey:subRelationComplexKey];
                    }
                }
                
            }
            [processedRelations setValue:statementMapping forKey:relationComplexKey];
            
        }else{
            
            SRKMappingRelation * relation = [SRKMappingRelation relationWithComplexKey:relationComplexKey];
            
            if (relation) {
                SRKObjectMapping *  relationMapping = [self _getObjectMapping:data];
                if (relationMapping) {
                    relation.mapping = relationMapping;
                    [processedRelations setValue:relation forKey:relation.toKey];
                }
            }
            
          
        }
        
    }
    
    // process current permanent properties
    
    for (NSString * key in _permanent) {
        [permanentProperties setValue:[_permanent valueForKey:key] forKey:key];
    }
    
    
    SRKObjectMapping  * mapping =  [[SRKObjectMapping alloc] init];
    
    
    
//  TODO  
//    if ([dictionary valueForKey:@"fetched"]) {
//        [mapping setFetched:[[dictionary valueForKey:@"fetched"] boolValue]];
//    }
    
    
    mapping.className=className;
    mapping.storageName = storageName;
    mapping.objectIdentifierKeyPath = identifierKeyPath;
    mapping.keyPath = keyPath;
    
    
    mapping.permanent = permanentProperties;
    mapping.relations = processedRelations;
    mapping.properties = properties;
    
    
    return mapping;
    
}




@end
