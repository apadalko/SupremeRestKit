//
//  SRKClient.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>
#import "SRKRequest.h"
#import "SRKMappingScope.h"
#import "SRKObjectMapper.h"
@class SRKClient;

typedef NSError  * _Nullable (^SRKErrorProccessingBlock) (NSError * _Nonnull error,NSURLSessionTask * _Nonnull task);

@interface SRKClient : AFHTTPSessionManager

-(void)makeRequest:(SRKRequest * _Nonnull)request;
-(void)regsiterMappingScope:(SRKMappingScope * _Nonnull)mappingScope;

@property (nonnull,retain,nonatomic)SRKObjectMapper * objectMapper;
@property (nonatomic,copy)_Nullable SRKErrorProccessingBlock errorProcessingBLock;



@end
