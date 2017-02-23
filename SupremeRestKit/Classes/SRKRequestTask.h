//
//  SRKRequestTask.h
//  Pods
//
//  Created by Alex Padalko on 2/22/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class SRKRequest;
@class AFHTTPSessionManager;

typedef NSError  * _Nullable (^SRKErrorProccessingBlock) (NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);

@interface SRKRequestTask : NSObject


+(instancetype)taskWithRequest:(NSURLRequest*)request sessionManager:(AFHTTPSessionManager*)sessionManager;

@property (nonatomic,retain,readonly)NSURLRequest * request;
@property (nonatomic,readonly,retain)AFHTTPSessionManager * sessionManager;
@property (nonatomic,copy)_Nullable SRKErrorProccessingBlock errorProcessingBLock;

-(void)start:(void(^)(id  _Nullable responseObject, NSError * _Nullable error)) completionBlock;

@end
NS_ASSUME_NONNULL_END
