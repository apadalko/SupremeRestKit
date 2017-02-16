//
//  SRKMappingScope.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKMappingScope.h"
#import "SRKObjectMapping_Private.h"
@interface SRKMappingScope ()

@property (nonatomic,retain)NSMutableDictionary * mappingData;
@property (nonatomic,retain)NSMutableDictionary * processedMappings;



@end
@implementation SRKMappingScope
-(instancetype)initWithFile:(NSString*)filepath{
    ;
    NSData * d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filepath ofType:@"json"]];
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

-(id)_getObjectMapping:(id)mapping{
    
    
    if ([mapping isKindOfClass:[NSString class]]) {
        id data = [self.processedMappings valueForKey:mapping];
        if (data) {
            return  data;
        }else{
            id data = [self.mappingData valueForKey:mapping];
            SRKObjectMapping * objectMapping = [self _getObjectMapping:data];
            return objectMapping;
        }
    }else if ([mapping isKindOfClass:[NSDictionary class]]){
        SRKObjectMapping * objectMapping = [self _generateMappingFromDictionary:mapping];
        return objectMapping;
    }else if ([mapping isKindOfClass:[SRKObjectMapping class]]){
        
        //TODO
        SRKObjectMapping * mappingObject = nil; // [self _getObjectMapping:[mapping mj_keyValues]];
        
        //        SRKObjectMapping * mappingObject = mapping;
        //        NSMutableDictionary * processedRelations = [[NSMutableDictionary alloc] init];
        //        for (NSString * key in [mappingObject relations]) {
        //
        //            SRKObjectMapping * subMapping = [self _getObjectMapping:[[mappingObject relations] valueForKey:key]];
        //            [processedRelations setValue:subMapping forKey:key];
        //        }
        //        mappingObject.relations=processedRelations;
        //
        return mappingObject;
    }else return nil;
}



-(SRKObjectMapping*)_generateMappingFromDictionary:(NSMutableDictionary*)dictionary{
    NSString * className = [dictionary valueForKey:@"className"];
    NSString * extends = [dictionary valueForKey:@"extends"];
    NSDictionary * props = [dictionary valueForKey:@"properties"];
    NSArray * relations = [dictionary valueForKey:@"relations"];
    
    if (!className&&!extends&&!props&&!relations) {
        
        return (SRKObjectMapping*)dictionary;
    }
    
    NSMutableDictionary * properties = [[NSMutableDictionary alloc] initWithDictionary:props];
    
    NSString * identifierKeyPath = [dictionary valueForKey:@"identifier"];
    
    NSMutableDictionary * processedRelations = [[NSMutableDictionary alloc] init];
    
    if (!properties) {
        properties=[[NSMutableDictionary alloc] init];
    }
    if (extends) {
        SRKObjectMapping * subMapping = [self _getObjectMapping:[dictionary valueForKey:@"extends"]];
        for (NSString* key in [subMapping properties]) {
            [properties setValue:[[subMapping properties] valueForKey:key] forKey:key];
        }
        for (NSString* key in [subMapping relations]) {
            [processedRelations setValue:[[subMapping relations] valueForKey:key] forKey:key];
        }
        if (!className) {
            className=[subMapping className];
        }
        if (!identifierKeyPath) {
            identifierKeyPath=[subMapping objectIdentifierKeyPath];
        }
    }
    //process relations
    
    
    
    for (NSString * key in relations) {
        
        if ([key hasPrefix:@"?"]) {
            
            id subMappings  = [relations valueForKey:key];
            NSMutableDictionary * statementMapping = [[NSMutableDictionary alloc] init];
            for (NSString * k in subMappings) {
                id subMapping = [self _getObjectMapping:[subMappings valueForKey:k]];
                [statementMapping setValue:subMapping forKey:k];
            }
            [processedRelations setValue:statementMapping forKey:key];
            
        }else{
            id subMapping = [self _getObjectMapping:[relations valueForKey:key]];
            
            
            [processedRelations setValue:subMapping forKey:key];
        }
        
    }
    
    
    SRKObjectMapping  * mapping =  [[SRKObjectMapping alloc] init];
    
    
    
//  TODO  
//    if ([dictionary valueForKey:@"fetched"]) {
//        [mapping setFetched:[[dictionary valueForKey:@"fetched"] boolValue]];
//    }
    
    
    mapping.className=className;
    mapping.relations=processedRelations;
    mapping.properties=properties;
    //TODO
    
//    mapping.permanent=[dictionary valueForKey:@"permanent"];
    mapping.keyPath=[dictionary valueForKey:@"keyPath"];
    mapping.objectIdentifierKeyPath=identifierKeyPath;
    
    
    
    return mapping;
    
}
@end
