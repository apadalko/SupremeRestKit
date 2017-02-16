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
@class SRKClient;

typedef NSError  * _Nullable (^SRKErrorProccessingBlock) (NSError * _Nonnull error,NSURLSessionTask * _Nonnull task);

@interface SRKClient : NSObject

-(instancetype)initWithBaseURL:(NSURL *)url;
-(instancetype)initWithBaseURL:(NSURL *)url andScope:(SRKMappingScope*)scope;

-(void)makeRequest:(SRKRequest * _Nonnull)request;
-(void)setMappingScope:(SRKMappingScope * _Nonnull)mappingScope;

@property (nonnull,retain,nonatomic)SRKObjectMapper * objectMapper;
@property (nonatomic,copy)_Nullable SRKErrorProccessingBlock errorProcessingBLock;



@end
