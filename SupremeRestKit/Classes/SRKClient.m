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
        
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        [serializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
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

-(void)makeRequest:(SRKRequest *)request{

    
    
    
    NSError *serializationError = nil;
    NSMutableURLRequest * urlRequest = [request generateRequestWithBaseURL:self.sessionManager.baseURL serializer:[self.sessionManager requestSerializer] error:&serializationError];
    if (serializationError) {

        
//        return nil;
    }else{
        __block NSURLSessionDataTask *dataTask = nil;
        dataTask = [self.sessionManager dataTaskWithRequest:urlRequest
                                             uploadProgress:nil
                                           downloadProgress:nil
                                          completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                              if (error) {
                                                  
                                                  [self _processError:error withTask:dataTask responseBlock:request.responseBlock];
                                                  
                                              } else {
                                                  [self _processSuccess:responseObject urlPattern:request.urlPath mappings:request.mapping responseBlock:request.responseBlock];
                                              }
                                          }];
        
        
        [dataTask resume];
    }
    


    
    
    
    
    
    
    
    
    
    
    
    
//    if (request.method==SRKRequestMethodGET){
//        [self _GET:request.urlPath params:request.urlParams mappings:request.mapping responseBlock:request.responseBlock];
//    }else if (request.method==SRKRequestMethodPOST){
//        
//        [self _POST:request.urlPath  params:request.urlParams body:request.body mappings:request.mapping multiparts:[request multiparts] responseBlock:request.responseBlock];
//    }else if (request.method==SRKRequestMethodPUT){
//        
//        [self _PUT:request.urlPath  params:request.urlParams body:request.body mappings:request.mapping multiparts:[request multiparts] responseBlock:request.responseBlock];
//    }else if (request.method==SRKRequestMethodDELETE){
//        
//        [self _DELETE:request.urlPath  params:request.urlParams body:request.body mappings:request.mapping multiparts:[request multiparts] responseBlock:request.responseBlock];
//    }
    
    
}
-(void)_DELETE:(NSString*)url params:(NSDictionary*)params body:(NSDictionary*)body mappings:(id)mappings multiparts:(NSArray*)multiparts responseBlock:(SRKResponseBlock)responseBlock{
    
    [self.sessionManager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self _processError:error withTask:task responseBlock:responseBlock];
    }];
}
-(void)_POST:(NSString*)url params:(NSDictionary*)params body:(NSDictionary*)body mappings:(id)mappings multiparts:(NSArray*)multiparts responseBlock:(SRKResponseBlock)responseBlock{
    
    NSString * fullUrl ;
    if (!params) {
        fullUrl=url;
    }else{
        NSString * k =  AFQueryStringFromParameters(params);
        fullUrl= [NSString stringWithFormat:@"%@?%@",url,k];
    }
    __block NSArray * mp = multiparts;
    
    if (multiparts.count>0) {
        
        
        [self.sessionManager POST:fullUrl parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            for (SRKMultipart * p in mp) {
                [formData appendPartWithFileData:[p data] name:[p name] fileName:[p fileName] mimeType:[p mimeType]];
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //            dispatch_async(self.workQueue, ^{
            [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
            //            });
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self _processError:error withTask:task responseBlock:responseBlock];
        }];
    }else{
        [self.sessionManager POST:fullUrl parameters:body progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //            dispatch_async(self.workQueue, ^{
            [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
            //            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self _processError:error withTask:task responseBlock:responseBlock];
            
        }];
    }
    
    
    
}
-(void)_PUT:(NSString*)url params:(NSDictionary*)params body:(NSDictionary*)body mappings:(id)mappings multiparts:(NSArray*)multiparts responseBlock:(SRKResponseBlock)responseBlock{
    NSString * fullUrl ;
    if (!params) {
        fullUrl=url;
    }else{
        NSString * k =  AFQueryStringFromParameters(params);
        fullUrl= [NSString stringWithFormat:@"%@?%@",url,k];
    }
    __block NSArray * mp = multiparts;
    
    if (multiparts.count>0) {
        
        id req = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:[NSString stringWithFormat:@"%@%@",[self.sessionManager.baseURL absoluteString],url] parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (SRKMultipart * p in mp) {
                [formData appendPartWithFileData:[p data] name:[p name] fileName:[p fileName] mimeType:[p mimeType]];
            }
        } error:nil];
        
        
        
        NSURLSessionDataTask * task =   [self.sessionManager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (error) {
                [self _processError:error withTask:task responseBlock:responseBlock];
                
            }else{
                [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
            }
            
        }];
        [task resume];
    }else{
        
        [self.sessionManager PUT:fullUrl parameters:body success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self _processError:error withTask:task responseBlock:responseBlock];
        }];
    }
    
    
    
}
-(void)_GET:(NSString*)url params:(NSDictionary*)params mappings:(id)mappings responseBlock:(SRKResponseBlock)responseBlock{
    [self.sessionManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        dispatch_async(self.workQueue, ^{
        [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
        //        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self _processError:error withTask:task responseBlock:responseBlock];
    }];
    
}


-(void)_processSuccess:(id)responseObject urlPattern:(NSString*)urlPattern mappings:(id)mappings responseBlock:(SRKResponseBlock)responseBlock{
    
    
    [self.objectMapper processDataInBackground:responseObject forMapping:mappings?mappings:urlPattern complitBlock:^(NSArray *result) {
        if (responseBlock) {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            SRKResponse * response = [[SRKResponse alloc] init];
            response.success=YES;
            response.objects=result;
            response.rawData=responseObject;
            responseBlock(response);
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
