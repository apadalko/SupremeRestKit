//
//  SRKClient.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKClient.h"
#import "SRKRequest_Private.h"
#import <AFNetworking/AFNetworking.h>

@interface SRKClient ()

@property (nonatomic,retain)AFHTTPSessionManager * sessionManager;
@property (nonatomic,retain)NSMutableArray  * cleanHeaderFields;
@property (nonatomic,retain)SRKMappingScope * mappingScope;
@property (nonatomic,retain)dispatch_queue_t workQueue;
@property (nonatomic,retain)NSMutableArray * requestQueue;
@property (nonatomic)BOOL makingStartRequest;
@end
@implementation SRKClient



-(instancetype)initWithBaseURL:(NSURL *)url{
    return [self initWithBaseURL:url andScope:[SRKMappingScope defaultScope]];
}
-(instancetype)initWithBaseURL:(NSURL *)url andScope:(SRKMappingScope*)scope{
    if (self=[super init]) {
        
        self.mappingScope=scope;
        
        self.sessionManager=[[AFHTTPSessionManager alloc] initWithBaseURL:url];
        
        [self.sessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html",@"*/*", nil]];
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        [serializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [serializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        [serializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        serializer.timeoutInterval = 20.0;
        [self.sessionManager setRequestSerializer:serializer];
    }
    return self;
}


-(dispatch_queue_t)workQueue{
    if (!_workQueue) {
        _workQueue=dispatch_queue_create("com.ap.SRKClient", 0);
    }
    return _workQueue;
}
-(void)setMappingScope:(SRKMappingScope*)mappingScope{
    _mappingScope=mappingScope;
    self.objectMapper=[[SRKObjectMapper alloc] initWithScope:mappingScope];
}

-(void)cleanAuthorization{
    
    for (NSString * k  in _cleanHeaderFields) {
        
        [[self.sessionManager requestSerializer] setValue:nil forHTTPHeaderField:k];
    }
    [self.cleanHeaderFields removeAllObjects];
    
    [[self.sessionManager requestSerializer] setValue:nil forHTTPHeaderField:@"Authorization"];
    
}

#pragma mark - work

-(void)makeRequest:(SRKRequest *)_request{
    
    
    
    SRKRequest * request = _request;
    
    
    
    
    NSError *serializationError = nil;
    NSMutableURLRequest * urlRequest = [request generateRequestWithBaseURL:self.sessionManager.baseURL serializer:[self.sessionManager requestSerializer] error:&serializationError];
    
    SRKResponseBlock responseBlock =   request.responseBlock;
    
    if (serializationError) {
        
        
        //        return nil;
    }else{
        __block NSURLSessionDataTask *dataTask = nil;
        __weak SRKClient *  weakSelf = self;
        
        dataTask = [self.sessionManager dataTaskWithRequest:urlRequest
                                             uploadProgress:nil
                                           downloadProgress:nil
                                          completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                              
                                              if (error) {
                                                  
                                                  [weakSelf _processError:error withTask:dataTask responseBlock:responseBlock];
                                                  
                                              } else {
                                                  
                                                  [weakSelf _processSuccess:responseObject urlPattern:[request.urlPath copy] mappings:request.mapping responseBlock:request.responseBlock];
                                              }
                                          }];
        
        
        [dataTask resume];
    }
    
    
    
    
    
    
    
}


-(void)_processSuccess:(id)responseObject urlPattern:(NSString*)urlPattern mappings:(id)mappings responseBlock:(SRKResponseBlock)responseBlock{
    
    
    [self.objectMapper processDataInBackground:responseObject forMapping:mappings?mappings:urlPattern complitBlock:^(NSArray *result) {
        if (responseBlock) {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            SRKResponse * response = [[SRKResponse alloc] init];
            response.success=YES;
            response.objects=result;
            response.rawData=responseObject;
            if (responseBlock) {
                responseBlock(response);
            }
            
            //            });
            
        }
    }];
    
    
    
    
    
}
//
-(SRKObjectMapper *)objectMapper{
    if (!_objectMapper) {
        _objectMapper=[[SRKObjectMapper alloc] init];
    }
    return _objectMapper;
}


-(void)_processError:(NSError*)_error withTask:(NSURLSessionTask*)task responseBlock:(SRKResponseBlock)responseBlock{
    
    
    
    NSError * error;
    
    if (self.errorProcessingBLock) {
        error=self.errorProcessingBLock(_error,task);
    }else{
        error=_error;
    }
    
    SRKResponse * response = [[SRKResponse alloc] init];
    response.error=error;
    response.success=NO;
    if (responseBlock) {
        responseBlock(response);
    }
    
}
#pragma mark -
-(NSMutableArray *)cleanHeaderFields{
    if (!_cleanHeaderFields) {
        _cleanHeaderFields=[[NSMutableArray alloc] init];
    }
    return _cleanHeaderFields;
}
-(NSMutableArray *)requestQueue{
    if (!_requestQueue) {
        _requestQueue=[[NSMutableArray alloc] init];
    }
    return _requestQueue;
}
@end
