//
//  SRKRequestOperation.h
//  Pods
//
//  Created by Alex Padalko on 2/22/17.
//
//

#import <Foundation/Foundation.h>
#import "SRKMappingTask.h"
#import "SRKRequestTask.h"
#import "SRKResponse.h"
#import "SRKDependencyRule.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,SRKOperationState)  {
    SRKOperationStateNone,
    SRKOperationStateMakingRequest,
    SRKOperationStateParsing,
    SRKOperationStateFinished,
    SRKOperationStateFailed
    
    
};

typedef void (^SRKRequestOperationComplitBlock) (SRKResponse* response);


@interface SRKRequestOperation : NSOperation

+(instancetype)operationWithMappingTask:(SRKMappingTask*)mappingTask andData:(id)data complitBlock:(void(^)(SRKResponse* response))completionBlock;
+(instancetype)operationWithRequestTask:(SRKRequestTask*)requestTask andMappingTask:(SRKMappingTask*)mappingTask complitBlock:(void(^)(SRKResponse* response))completionBlock;

@property (nonatomic, strong, readonly, nullable) SRKMappingTask * mappingTask;
@property (nonatomic, strong, readonly, nullable) SRKRequestTask * requestTask;
@property (nonatomic,readonly)SRKOperationState state;
@property (nonatomic,copy)SRKRequestOperationComplitBlock completionBlock;
@property (nonatomic,retain,readonly)SRKResponse * result;

@property (nonatomic,retain)NSString * customQueueName;


-(void)addDependency:(NSOperation *)op withRule:(SRKDependencyRule*)rule;


@end
NS_ASSUME_NONNULL_END
