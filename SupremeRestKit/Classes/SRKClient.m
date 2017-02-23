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
@property (nonatomic,retain)NSMutableArray * pendingRequestQueue;


@property (nonatomic,retain)NSOperationQueue * mainOperationQueue;
@property (nonatomic,retain)NSOperationQueue * testOperationQueue;


@property (nonatomic,retain)NSURLSessionConfiguration * sessionConfig;

@end
@implementation SRKClient



-(instancetype)initWithBaseURL:(NSURL *)url{
    return [self initWithBaseURL:url andScope:[SRKMappingScope defaultScope]];
}
-(instancetype)initWithBaseURL:(NSURL *)url andScope:(SRKMappingScope*)scope{
    if (self=[super init]) {
        self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
               self.sessionConfig.HTTPMaximumConnectionsPerHost=100;
        self.pendingRequestQueue = [[NSMutableArray alloc] init];
        self.mappingScope=scope;

        self.sessionManager=[[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:self.sessionConfig];
        self.sessionManager.operationQueue.maxConcurrentOperationCount=100;
      
        [self.sessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html",@"*/*", nil]];
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        [serializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [serializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        [serializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        serializer.timeoutInterval = 20.0;
        [self.sessionManager setRequestSerializer:serializer];
        
 
        self.mainOperationQueue = [[NSOperationQueue alloc] init];
        self.mainOperationQueue.maxConcurrentOperationCount = 10;
        
             self.testOperationQueue = [[NSOperationQueue alloc] init];
        self.testOperationQueue.maxConcurrentOperationCount = 10;

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



#pragma mark - work

-(SRKRequest*)makeRequest:(SRKRequest *)_request{
    
    dispatch_async(self.workQueue, ^{
        
        if (!_request) {
            NSLog(@"fail");
         
            return;
        }
        [self.pendingRequestQueue addObject:_request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(self.workQueue, ^{

                
                if (self.pendingRequestQueue.count>0) {
                    NSArray * tempArray = [[NSArray alloc] initWithArray:self.pendingRequestQueue];
                    [self.pendingRequestQueue removeAllObjects];
                    
                    
                    
                    SRKRequest * req1 = [tempArray objectAtIndex:0];
                     SRKRequest * req2 = [tempArray objectAtIndex:1];
                    SRKRequest * req3 = [tempArray objectAtIndex:2];
                    
                    NSOperation * operation1 = [self _operationFromRequest:req1];
                         NSOperation * operation2 = [self _operationFromRequest:req2];
                    NSOperation * operation3 = [self _operationFromRequest:req3];
                    
                    [operation3 addDependency:operation1];
                    [operation1 addDependency:operation2];
                     [operation3 addDependency:operation2];
                    
                    [self.mainOperationQueue addOperation:operation1];
                    [self.mainOperationQueue addOperation:operation2];
                     [self.testOperationQueue addOperation:operation3];
                    
                    for (int a = 3 ; a < tempArray.count;a++){
                        SRKRequest * request = tempArray[a];
                        NSOperation * operation = [self _operationFromRequest:request];
                        if (operation) {
                            [self.mainOperationQueue addOperation:operation];
                            
                        }

                    }
                    
                    //                for (SRKRequest * request in tempArray){
                    //
                    //
//                                        NSOperation * operation = [self _operationFromRequest:request];
//                                        if (operation) {
//                                            [self.mainOperationQueue addOperation:operation];
//                    
//                                        }
                    //
                    //                }
                }
                

                
            });
        });
    
        
   
    });
   
    
    return  _request;

    
}

-(SRKRequestOperation*)_operationFromRequest:(SRKRequest*)request{
    
    NSError *serializationError = nil;
    NSMutableURLRequest * urlRequest = [request generateRequestWithBaseURL:self.sessionManager.baseURL serializer:[self.sessionManager requestSerializer] error:&serializationError];
    
    SRKResponseBlock responseBlock =   request.responseBlock;
    
    if (!serializationError) {
        
        id mapping = request.mapping?request.mapping:request.urlPath;
        
        SRKRequestOperation * operation = [SRKRequestOperation operationWithRequestTask:[SRKRequestTask taskWithRequest:urlRequest sessionManager:self.sessionManager] andMappingTask:[SRKMappingTask taskWithMapping:mapping scope:self.mappingScope] complitBlock:[request responseBlock]];
        
        
        
        return operation;
    }else{
        
        SRKResponse * response = [[SRKResponse alloc] init];
        response.success = false;
        response.error  = [NSError errorWithDomain:@"TODO: bad request processing (ERROR on frontend)" code:-7771 userInfo:nil];
        request.responseBlock(response);
        return  nil;
    }
}

#pragma mark - set/get
-(void)setMainQueueAsyncSize:(NSInteger)mainRequestQueueSize{
    self.mainOperationQueue.maxConcurrentOperationCount = mainRequestQueueSize;
}
-(NSInteger)mainQueueAsyncSize{
    return self.mainOperationQueue.maxConcurrentOperationCount;
}

#pragma mark  serializers

-(AFHTTPRequestSerializer *)requestSerialized{
    return self.sessionManager.requestSerializer;
}
-(AFHTTPResponseSerializer *)responseSerializer{
    return self.sessionManager.responseSerializer;
}
-(void)setReuqestSerializer:(AFHTTPRequestSerializer *)requestSerializer{
    [self.sessionManager setRequestSerializer:requestSerializer];
}
-(void)setResponseSerializer:(AFHTTPRequestSerializer *)responseSerializer{
    [self.sessionManager setResponseSerializer:responseSerializer];
}


#pragma mark -

@end
