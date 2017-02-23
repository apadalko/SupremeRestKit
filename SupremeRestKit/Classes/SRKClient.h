//
//  SRKClient.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "SRKRequest.h"
#import "SRKMappingScope.h"
#import "SRKObjectMapper.h"
#import "SRKRequestOperation.h"

#import <AFNetworking/AFNetworking.h>
@class SRKClient;



@interface SRKClient : NSObject

-(instancetype)initWithBaseURL:(NSURL *)url;
-(instancetype)initWithBaseURL:(NSURL *)url andScope:(SRKMappingScope*)scope;

-(SRKRequest*)makeRequest:(SRKRequest * _Nonnull)request;
-(void)setMappingScope:(SRKMappingScope * _Nonnull)mappingScope;

@property (nonnull,retain,nonatomic)SRKObjectMapper * objectMapper;
@property (nonatomic,copy)_Nullable SRKErrorProccessingBlock errorProcessingBLock;



@property (nonatomic)NSInteger mainQueueAsyncSize; // 10




-(AFHTTPResponseSerializer*)responseSerializer;
-(void)setResponseSerializer:(AFHTTPRequestSerializer*)responseSerializer;


-(AFHTTPRequestSerializer*)requestSerialized;
-(void)setReuqestSerializer:(AFHTTPRequestSerializer*)requestSerializer;


@end
