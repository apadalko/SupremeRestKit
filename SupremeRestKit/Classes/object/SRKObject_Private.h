//
//  SRKObject_Private.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/18/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import "SRKObject.h"
extern NSString *const kSRKIdentifier;

@interface SRKObject ()


+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data sync:(BOOL)sync;

@property (nullable, nonatomic, strong) NSString * identifier;

-(instancetype)syncObject:(BOOL)isFetched associatedObjects:(NSArray*)objects;





#pragma mark -

+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data storageName:(NSString* _Nullable)storageName;
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data sync:(BOOL)sync storageName:(NSString* _Nullable)storageName;
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data sync:(BOOL)sync;
-(void)setCustomStorageName:(NSString * _Nonnull)storageName;


////
-(void)setLocked:(BOOL)locked;
-(BOOL)allowedToUseRamStorage;
-(NSString*)_srk_objectType;
-(NSString*)storageName;


-(void)copyToObject:(SRKObject*)toObject override:(BOOL)override;
@end
