//
//  SRKRequestTask.m
//  Pods
//
//  Created by Alex Padalko on 2/22/17.
//
//

#import "SRKRequestTask.h"
#import "SRKRequest_Private.h"
#import <AFNetworking/AFNetworking.h>
@implementation SRKRequestTask
+(instancetype)taskWithRequest:(NSURLRequest*)request sessionManager:(AFHTTPSessionManager*)sessionManager{
    
    return [[self alloc] initWithRequest:request sessionManager:sessionManager];
}

-(instancetype)initWithRequest:(SRKRequest*)request sessionManager:(AFHTTPRequestSerializer*)sessionManager{
    if (self=[super init]) {
        _request=request;
        _sessionManager = sessionManager;
    }
    return self;
}

-(void)start:(void(^)(id  _Nullable responseObject, NSError * _Nullable error)) completionBlock{
 
    
   NSURLSessionDataTask * task =  [self.sessionManager dataTaskWithRequest:self.request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
       
       NSError * processedError = nil;
       if (self.errorProcessingBLock) {
           NSError * processedError  = self.errorProcessingBLock(response,responseObject,error);
           
       }else {
           processedError = error;
       }
       
       if (processedError) {
           completionBlock(nil,processedError);
       }else{
           completionBlock(responseObject,nil);
       }
    }];
    
    [task resume];
    
}

@end
