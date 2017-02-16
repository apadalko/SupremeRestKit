//
//  SRKClient.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKClient.h"

@interface SRKClient ()
@property (nonatomic,retain)NSMutableArray  * cleanHeaderFields;
@property (nonatomic,retain)SRKMappingScope * mappingScope;
@property (nonatomic,retain)dispatch_queue_t workQueue;
@property (nonatomic,retain)NSMutableArray * requestQueue;
@property (nonatomic)BOOL makingStartRequest;
@end
@implementation SRKClient
-(dispatch_queue_t)workQueue{
    if (!_workQueue) {
        _workQueue=dispatch_queue_create("com.ap.SRKClient", 0);
    }
    return _workQueue;
}
-(void)regsiterMappingScope:(SRKMappingScope*)mappingScope{
    self.mappingScope=mappingScope;
    self.objectMapper=[[SRKObjectMapper alloc] initWithScope:mappingScope];
}

-(void)cleanAuthorization{
    
    for (NSString * k  in _cleanHeaderFields) {
        
        [[self requestSerializer] setValue:nil forHTTPHeaderField:k];
    }
    [self.cleanHeaderFields removeAllObjects];
    
    [[self requestSerializer] setValue:nil forHTTPHeaderField:@"Authorization"];
    
}

#pragma mark - work

-(void)makeRequest:(SRKRequest *)request{

    if (request.method==SRKRequestMethodGET){
        [self _GET:request.urlPath params:request.params mappings:request.mapping responseBlock:request.responseBlock];
    }else if (request.method==SRKRequestMethodPOST){
        
        [self _POST:request.urlPath  params:request.params body:request.body mappings:request.mapping multiparts:[request multiparts] responseBlock:request.responseBlock];
    }else if (request.method==SRKRequestMethodPUT){
        
        [self _PUT:request.urlPath  params:request.params body:request.body mappings:request.mapping multiparts:[request multiparts] responseBlock:request.responseBlock];
    }else if (request.method==SRKRequestMethodDELETE){
        
        [self _DELETE:request.urlPath  params:request.params body:request.body mappings:request.mapping multiparts:[request multiparts] responseBlock:request.responseBlock];
    }
    
    
}
-(void)_DELETE:(NSString*)url params:(NSDictionary*)params body:(NSDictionary*)body mappings:(id)mappings multiparts:(NSArray*)multiparts responseBlock:(SRKResponseBlock)responseBlock{
    
    [self DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
        
        [self POST:fullUrl parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
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
        [self POST:fullUrl parameters:body progress:^(NSProgress * _Nonnull uploadProgress) {
            
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
        
        id req = [self.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:[NSString stringWithFormat:@"%@%@",[self.baseURL absoluteString],url] parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (SRKMultipart * p in mp) {
                [formData appendPartWithFileData:[p data] name:[p name] fileName:[p fileName] mimeType:[p mimeType]];
            }
        } error:nil];
        
        NSURLSessionDataTask * task =   [self dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (error) {
                [self _processError:error withTask:task responseBlock:responseBlock];
                
            }else{
                [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
            }
            
        }];
        [task resume];
    }else{
        
        [self PUT:fullUrl parameters:body success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self _processError:error withTask:task responseBlock:responseBlock];
        }];
    }
    
    
    
}
-(void)_GET:(NSString*)url params:(NSDictionary*)params mappings:(id)mappings responseBlock:(SRKResponseBlock)responseBlock{
    [self GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        dispatch_async(self.workQueue, ^{
        [self _processSuccess:responseObject urlPattern:url mappings:mappings responseBlock:responseBlock];
        //        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self _processError:error withTask:task responseBlock:responseBlock];
    }];
    
}


-(void)_processSuccess:(id)responseObject urlPattern:(NSString*)urlPattern mappings:(id)mappings responseBlock:(SRKResponseBlock)responseBlock{
    
    
    
    
    [self.objectMapper processData:responseObject forMapping:mappings?mappings:urlPattern complitBlock:^(NSArray *result) {
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
