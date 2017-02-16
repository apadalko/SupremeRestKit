//
//  SRKObjectMapper.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKObjectMapper.h"
#import "SRKObjectMapper.h"
#import <DSObject/DSObject_Private.h>
@interface SRKObjectMapper ()
@property (nonatomic,retain)SRKMappingScope * scope;
@property (nonatomic,retain)dispatch_queue_t workQueue;

@end
@implementation SRKObjectMapper
-(instancetype)initWithScope:(SRKMappingScope *)scope{
    if(self=[super init]){
        self.scope=scope;
    }
    return self;
}
-(dispatch_queue_t)workQueue{
    if (!_workQueue) {
        _workQueue=dispatch_queue_create("com.ap.SRKObjectMapper", 0);
    }
    return _workQueue;
}
-(void)processData:(NSDictionary *)data forMapping:(id)_maping complitBlock:(void (^)(NSArray *))complitBlock{
    
    
    NSArray * objectMappings = [[self scope] getObjectMappings:_maping];
    
    if (!objectMappings && [_maping isKindOfClass:[SRKObjectMapping class]]) {
        objectMappings = @[_maping];
    }
    
    dispatch_async(self.workQueue, ^{
        NSMutableArray * itemsResult = [[NSMutableArray alloc] init];
        for (SRKObjectMapping * mapping in objectMappings) {
            
            id workValue = nil;
            
            NSString * keyPath = [mapping valueForKey:@"keyPath"];
            if (keyPath.length>0) {
                workValue=[data valueForKeyPath:keyPath];
            }else{
                workValue=data;
            }
            
            if ([workValue isKindOfClass:[NSArray class]]) {
                for (id subValue in workValue) {
                    id  val = [self _processData:subValue forMapping:mapping ];
                    
                    if (val) {
                        [itemsResult addObject:val];
                    }
                }
            }else if ([workValue isKindOfClass:[NSDictionary class]]&&[workValue allKeys].count>0) {
                id val = [self _processData:workValue forMapping:mapping];
                if (val) {
                    [itemsResult addObject:val];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue()
                       
                       , ^{
                           complitBlock(itemsResult);
                       });
        
    });
    
}
-(DSObject*)_processData:(NSDictionary *)data forMapping:(SRKObjectMapping *)mapping {
    return [self __processData:data forMapping:mapping fetched:YES];
    
}
-(DSObject*)__processData:(NSDictionary *)data forMapping:(SRKObjectMapping *)mapping fetched:(BOOL)fetched{
    
    ///process rel mapping
    NSString * clName = [mapping className];
    Class cl = NSClassFromString(clName);
    if (!cl) {
        cl=[DSObject class];
    }
    DSObject * rkObject = [[cl alloc] init];
    if (mapping.storageName) {
        [rkObject setCustomStorageName:mapping.storageName];
    }

    NSDictionary * properties =[mapping valueForKey:@"properties"];
    for (NSString * prop in properties) {
        id val = [data valueForKeyPath:prop];
        if (![val isEqual:[NSNull null]]&&val) {
            rkObject[[properties valueForKey:prop]]=val;
        }
        
    }
    if (mapping.objectIdentifierKeyPath) {
        rkObject[@"objectId"]=[data valueForKeyPath:mapping.objectIdentifierKeyPath];
    }
    
    NSDictionary * relations =[mapping valueForKey:@"relations"];
    for (NSString * key  in relations) {
        
        
        if ([key hasPrefix:@"?"]) {
            
            NSString * statement = [key substringFromIndex:1];
            
            BOOL res =  [self ppj_proccessBoolStatement:statement withData:data];
            
            if (!res) {
                continue;
            }
            NSDictionary * subRel = [relations valueForKeyPath:key];
            for (NSString * subKey in subRel) {
                [self proccessRelation:[subRel valueForKey:subKey] forKey:subKey inObject:rkObject withData:data fetched:fetched];
            }
            
            
        }else{
            
            [self proccessRelation:[relations valueForKey:key] forKey:key inObject:rkObject withData:data fetched:fetched];
        }
        
        
        
        
        
    }

    
   
    
    NSDictionary * permanent =[mapping valueForKey:@"permanent"];
    for (NSString * perpProp in permanent) {
        rkObject[perpProp]=[permanent valueForKey:perpProp];
    }
    
    return [rkObject localSync:fetched];
    
}

-(void)proccessRelation:(id)relation forKey:(NSString*)key inObject:(DSObject*)obj withData:(NSDictionary*)data fetched:(BOOL)fetched{
    
    NSArray * p = [key componentsSeparatedByString:@"->"];
    if (p.count!=2) {
        return;
    }
    id subData = nil;
    if ([[p firstObject] length]>0) {
        subData = [data valueForKeyPath:[p firstObject]];
    }else{
        subData=data;
    }
    if (!subData) {
        return;
    }
    
    id d = relation;
    NSString * toKey = [p lastObject];
    
    
    
    if ([d isKindOfClass:[SRKObjectMapping class]]) {
        SRKObjectMapping *  rel = d;
//        [rel setFetched:fetched];
        
        
        
        if ([subData isKindOfClass:[NSArray class]]) {
            
            NSMutableArray * result = [[NSMutableArray alloc] init];
            
            for (id subArrVal in subData) {
                DSObject * subObject  = [self __processData:subArrVal forMapping:rel fetched:fetched];
                if (subObject) {
                    [result addObject:subObject];
                }
            }
            [obj setObject:result forKey:toKey];
        }else{
            DSObject * subObject  = [self __processData:subData forMapping:rel fetched:fetched] ;
            [obj setObject:subObject forKey:toKey];
        }
        
        
    }else if ([d isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary * md =[[NSMutableDictionary alloc] init];
        for (NSString * k  in d) {
            
            id val =   [subData valueForKeyPath:k];
            if (val&&![val isEqual:[NSNull null]]) {
                [md setValue:val forKey:k];
            }
            
        }
        
        [obj setObject:md forKey:toKey];
    }
    
}

#pragma mark - s

-(BOOL)ppj_proccessBoolStatement:(NSString*)_statement withData:(NSDictionary*)data{
    
    NSArray * orParts = [_statement componentsSeparatedByString:@"||"];
    BOOL finalResult= YES;
    for (NSString * statement in orParts) {
        
        
        NSArray * andParts = [statement componentsSeparatedByString:@"&&"];
        
        
        
        for (NSString * _andPart in andParts) {
            BOOL result = NO;
            NSString * equasion = nil;
            BOOL requaredResult = NO;
            if ([_andPart containsString:@"!="]) {
                equasion=@"!=";
                requaredResult=NO;
            }else if ([_andPart containsString:@"=="]){
                equasion=@"==";
                requaredResult=YES;
            }else if ([_andPart containsString:@">"]){
                equasion=@">";
                requaredResult=YES;
            }else{
                requaredResult=YES;
            }
            
            BOOL leftReferenced=NO;
            NSString *andPart=_andPart;
            if (  [andPart hasPrefix:@"->"]) {
                andPart=[andPart substringFromIndex:2];
                leftReferenced=YES;
                
            }
            
            if (equasion) {
                
                NSArray *eqParts = [andPart componentsSeparatedByString:equasion];
                if (eqParts.count==2) {
                    id leftValue = nil;
                    id rightValue = nil;
                    NSString * leftKey = [eqParts firstObject];
                    NSString * rightKey = [eqParts lastObject];
                    if (leftReferenced) {
                        leftValue =[data valueForKeyPath:leftKey];
                    }else{
                        leftValue=leftKey;
                    }
                    if ([rightKey hasPrefix:@"->"]) {
                        rightKey =  [leftKey substringFromIndex:2];
                        rightValue = [data valueForKeyPath:rightKey];
                    }else{
                        rightValue=rightKey;
                    }
                    if ([rightValue isKindOfClass:[NSString class]]) {
                        rightValue=[rightValue stringByReplacingOccurrencesOfString:@"?" withString:@""];
                    }
                    
                    if ([equasion isEqualToString:@">"]) {
                        
                        if ([leftValue isKindOfClass:[NSNumber class]]) {
                            
                            result=[leftValue floatValue]>[rightValue floatValue];
                        }else if ([leftValue isKindOfClass:[NSString class]]){
                            result=[leftValue length]>[rightValue integerValue];
                        }else if ([leftValue isKindOfClass:[NSArray class]]){
                            result=[leftValue count]>[rightValue integerValue];
                        }else if ([leftValue isKindOfClass:[NSDictionary class]]){
                            result=[[leftValue allKeys] count]>[rightValue integerValue];
                        }else{
                            result=NO;
                        }
                        
                    }else{
                        if ([leftValue isKindOfClass:[NSNumber class]]) {
                            
                            result=[rightValue floatValue]==[leftValue floatValue];
                        }else if ([leftValue isKindOfClass:[NSString class]]){
                            result=[rightValue isEqualToString:leftValue];
                        }else if ([leftValue isKindOfClass:[NSArray class]]){
                            result=[leftValue  count]==[rightValue integerValue];
                        }
                    }
                    
                }else{
                    
                    finalResult=NO;
                    break;
                }
            }else{
                id leftValue = nil;
                NSString * leftKey = andPart;
                if ([leftKey hasPrefix:@"->"]) {
                    leftKey =  [leftKey substringFromIndex:2];
                }
                leftValue =[data valueForKeyPath:leftKey];
                
                result=leftValue?YES:NO;
            }
            
            if (result!=requaredResult) {
                finalResult=NO;
                
            }else
                finalResult=YES;
            
        }
        if (finalResult) {
            return finalResult;
        }
        
        
    }
    
    return  finalResult;
    
    
}

@end
