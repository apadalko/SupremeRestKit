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



@property (nonatomic)dispatch_queue_t workQueue;
@property (nonatomic,retain)NSMutableArray * pendingRequestQueue;

@property (nonatomic,retain)NSOperationQueue * mainOperationQueue;

@property (nonatomic,retain)NSMutableDictionary * customOperationsQueues;


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
      
        [self.sessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html",@"*/*",@"application/vnd.api+json", nil]];
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        [serializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [serializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        [serializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        serializer.timeoutInterval = 20.0;
        [self.sessionManager setRequestSerializer:serializer];
        
 
        self.mainOperationQueue = [[NSOperationQueue alloc] init];
        self.mainOperationQueue.maxConcurrentOperationCount = 10;
        self.customOperationsQueues = [[NSMutableDictionary alloc] init];


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
                    NSArray * operations =  [self someName:tempArray];
                    
                    for (SRKRequestOperation * op in operations) {
                        if ([op customQueueName]) {
                            [[self operationQueueByName:[op customQueueName]] addOperation:op];
                        }else{
                            [self.mainOperationQueue addOperation:op];   
                        }
                       
                    }
                    
                }
                

                
            });
        });
    
        
   
    });
   
    
    return  _request;

    
}

-(NSArray*)someName:(NSArray*)requests{
        NSMutableArray * independedRequests = [[NSMutableArray alloc] init];
    NSMutableArray * result = [[NSMutableArray alloc] init];

    NSMutableSet * processedRequests = [[NSMutableSet alloc] init];

    
    NSMutableSet * allRequests = [[NSMutableSet alloc] init];
    NSMutableDictionary * processedOperations = [[NSMutableDictionary alloc] init];
    [self extractRequestsFromArray:requests result:&allRequests fromRequest:nil];
    
    

    for (SRKRequest * request in allRequests) {
        NSString * indif = [NSString stringWithFormat:@"%p",request];
        SRKRequestOperation * op = [self _operationFromRequest:request];
        [processedOperations setValue:op forKey:indif];
    }
    for (SRKRequest * request in allRequests) {
    
        if (request.afterRequestsDependencies) {
            NSString * indif = [NSString stringWithFormat:@"%p",request];
            SRKRequestOperation * op = [processedOperations valueForKey:indif];
            
            if (op) {
                
                for (SRKRequestDependencyRule * dep in request.afterRequestsDependencies) {
                    NSString * subIndif = [NSString stringWithFormat:@"%p",   dep.request];
                    SRKRequestOperation * subOp = [processedOperations valueForKey:subIndif];
                    if (subOp) {
                        [op addDependency:subOp withRule:dep];
                    }
                }
                
            }
        }
      
    }
    
    return [processedOperations allValues];
    
    
}



#pragma mark - extraction
-(void)extractRequestsFromArray:(NSArray*)requests result:(NSMutableSet**)result fromRequest:(SRKRequest*)fromRequest{
    NSMutableSet * extractedArray = [[NSMutableSet alloc] init];
    for (SRKRequest * request in requests) {
        if ([request isEqual:fromRequest]) {
            continue;
        }
        [self extractRequestsFromRequest:request result:result fromRequest:nil];
    }
    
}
-(void)extractRequestsFromRequest:(SRKRequest*)request result:(NSMutableSet**)result fromRequest:(SRKRequest*)fromRequest{
    
    if (request.beforeRequests.count>0) {
        [self extractRequestsFromArray:request.beforeRequests result:result fromRequest:fromRequest];
    }
    
    for (SRKRequestDependencyRule * dep in request.afterRequestsDependencies) {
        [self extractRequestsFromRequest:dep.request result:result fromRequest:request];
    }
    
    [*result addObject:request];
    
}

#pragma mark - operation gen

-(SRKRequestOperation*)_operationFromRequest:(SRKRequest*)request{
    
    NSError *serializationError = nil;
    NSMutableURLRequest * urlRequest = [request generateRequestWithBaseURL:self.sessionManager.baseURL serializer:[self.sessionManager requestSerializer] error:&serializationError];
    
    SRKResponseBlock responseBlock =   request.responseBlock;
    
    if (!serializationError) {
        
        id mapping = request.mapping?request.mapping:request.urlPath;
        
        SRKRequestOperation * operation = [SRKRequestOperation operationWithRequestTask:[SRKRequestTask taskWithRequest:urlRequest sessionManager:self.sessionManager] andMappingTask:[SRKMappingTask taskWithMapping:mapping scope:self.mappingScope] complitBlock:[request responseBlock]];
        
        if (request.queueName) {
            [operation setCustomQueueName:request.queueName];
        }
        
        return operation;
    }else{
        
        SRKResponse * response = [[SRKResponse alloc] init];
        response.success = false;
        response.error  = [NSError errorWithDomain:@"TODO: bad request processing (ERROR on frontend)" code:-7771 userInfo:nil];
        request.responseBlock(response);
        return  nil;
    }
}

#pragma mark - custom queue management 


-(NSOperationQueue*)operationQueueByName:(NSString*)name{
    
    NSOperationQueue * op = [self.customOperationsQueues valueForKey:name];
    if (!op) {
        op = [[NSOperationQueue alloc] init];
        op.maxConcurrentOperationCount = 1;
        [self.customOperationsQueues setValue:op forKey:name];
    }
    
    return op;
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
