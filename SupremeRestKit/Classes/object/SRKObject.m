//
//  SRKObject.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/18/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import "SRKObject.h"
#import <DSObject/DSObject_Private.h>
#import <DSObject/DSObjectsRamStorage.h>
@implementation SRKObject

@dynamic localId;
@dynamic objectId;




-(NSString *)localId{
    id a = self[@"localId"];
    return a;
}
-(void)setLocalId:(NSString *)localId{
    self[@"localId"]=localId;
}

-(NSString *)objectId{
    id a = self[@"objectId"];
    return a;
}
-(void)setObjectId:(NSString *)objectId{
    self[@"objectId"]=objectId;
}







//-(void)
-(instancetype)syncObject:(BOOL)isFetched associatedObjects:(NSArray*)objects{
    
    if ([self allowedToUseRamStorage]) {
        SRKObject * obj =  [super sync:isFetched];
        
        //getting object from ram
        
        //if object id not present means that we already sync it in temp storage
        if ([obj allowedToUseRamStorage]&&[obj objectId]) {
            NSString * name =[NSString stringWithFormat:@"%@_TEMP", [super _ds_objectType] ];
            
            SRKObject * objectByLocalId = [[DSObjectsRamStorage storageForClassName:name] registerOrGetRecentObject:obj fromStorageByIndetifier:obj.localId];
            if (![objectByLocalId isEqual:obj]) {
                [obj copyToObject:objectByLocalId override:isFetched];
                obj = objectByLocalId;
            } 
        }
        return obj;
        
        if ([obj isEqual:self]) {
            return self;
        }
        
    }else{
        return self;
    }
    
}

-(BOOL)allowedToUseRamStorage;{
    return [self.class isSubclassOfClass:[SRKObject class]]||[self storageName]!=nil;
}
-(NSString *)identifier{
    return self.objectId?self.objectId:self.localId;
}
-(NSString *)_ds_objectType{
    NSString * name = [super _ds_objectType];
    if (!self.objectId) {
        return [NSString stringWithFormat:@"%@_TEMP",name];
    }else {
        return name;
    }
}






//-(NSString*)tempStorageName{
//    return <#expression#>
//}





#pragma mark - some basic setup
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable )data{
    DSAssert(self != [DSObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:nil andData:data];
    
}
+(instancetype)objectWithIdentifier:(NSString*)identifier{
    DSAssert(self != [DSObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:identifier andData:nil];
}
+(instancetype)objectWithIdentifier:(NSString*)identifier andData:(NSDictionary*)data{
    DSAssert(self != [DSObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:identifier andData:data];
}

@end
