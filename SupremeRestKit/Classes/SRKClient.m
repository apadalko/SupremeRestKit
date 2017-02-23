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


@interface _SRKNode : NSObject

@property (nonatomic,retain)NSMutableArray * subnodes;
@property (nonatomic,retain)_SRKNode * nextNode;

@property (nonatomic,retain)NSMutableArray * requests;

@end

@implementation _SRKNode

-(NSMutableArray *)subnodes{
    if (!_subnodes) {
        _subnodes=[[NSMutableArray alloc] init];
    }
    return _subnodes;
}
-(NSMutableArray *)requests{
    if (!_requests) {
        _requests=[[NSMutableArray alloc] init];
    }
    return _requests;
}
@end



@interface _SRKNode2 : NSObject

@property (nonatomic,retain)NSMutableArray * subnodes;
@property (nonatomic,retain)NSMutableArray * requests;
@property (nonatomic,retain)_SRKNode2 * leftNode;


@end

@implementation _SRKNode2

-(NSMutableArray *)subnodes{
    if (!_subnodes) {
        _subnodes=[[NSMutableArray alloc] init];
    }
    return _subnodes;
}
-(NSMutableArray *)requests{
    if (!_requests) {
        _requests=[[NSMutableArray alloc] init];
    }
    return _requests;
}
@end

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
                   NSArray * operations =  [self someName:tempArray];
                    
                    for (SRKRequestOperation * op in operations) {
                        [self.mainOperationQueue addOperation:op];
                    }
                    
//                    
//                    SRKRequest * req1 = [tempArray objectAtIndex:0];
//                     SRKRequest * req2 = [tempArray objectAtIndex:1];
//                    SRKRequest * req3 = [tempArray objectAtIndex:2];
//                    
//                    NSOperation * operation1 = [self _operationFromRequest:req1];
//                         NSOperation * operation2 = [self _operationFromRequest:req2];
//                    NSOperation * operation3 = [self _operationFromRequest:req3];
//                    
//                    [operation3 addDependency:operation1];
//                    [operation1 addDependency:operation2];
//                     [operation3 addDependency:operation2];
//                    
//                    [self.mainOperationQueue addOperation:operation1];
//                    [self.mainOperationQueue addOperation:operation2];
//                     [self.testOperationQueue addOperation:operation3];
//                    
//                    for (int a = 3 ; a < tempArray.count;a++){
//                        SRKRequest * request = tempArray[a];
//                        NSOperation * operation = [self _operationFromRequest:request];
//                        if (operation) {
//                            [self.mainOperationQueue addOperation:operation];
//                            
//                        }
//
//                    }
                    
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

-(NSArray*)someName:(NSArray*)requests{
        NSMutableArray * independedRequests = [[NSMutableArray alloc] init];
    NSMutableArray * result = [[NSMutableArray alloc] init];

    NSMutableSet * processedRequests = [[NSMutableSet alloc] init];
//    NSMutableDictionary * sequenceRequests = [[NSMutableDictionary alloc] init];
//    {
//        req1,
//        "groupname":[anchor,req1,req2,req3,req4];
//        "group2":[anchor,req,"group3":[anchor,req,req2,req3]]
//        req3
//}
    
    NSMutableSet * allRequests = [[NSMutableSet alloc] init];
    NSMutableDictionary * processedOperations = [[NSMutableDictionary alloc] init];
    [self extractRequestsFromArray:requests result:&allRequests fromRequest:nil];
    
    NSLog(@"???");
    
    
    _SRKNode2 * rootNode = nil;
    for (SRKRequest * request in allRequests) {
        
        NSString * indif = [NSString stringWithFormat:@"%p",request];
        
        SRKRequestOperation * op = [self _operationFromRequest:request];
    
        [processedOperations setValue:op forKey:indif];
        
//        NSLog(@"%@",indif);
        
//        if (rootNode == nil) {
//            rootNode = [[_SRKNode2 alloc] init];
//            [rootNode.requests addObject:request];
//        }else {
//            
//            //1 is equal
//            //0 is less
//            
//          
//        }
        
        
        
    }
    for (SRKRequest * request in allRequests) {
    
        if (request.afterRequestsDependencies) {
            NSString * indif = [NSString stringWithFormat:@"%p",request];
            SRKRequestOperation * op = [processedOperations valueForKey:indif];
            
            if (op) {
                
                for (SRKRequestDependency * dep in request.afterRequestsDependencies) {
                    NSString * subIndif = [NSString stringWithFormat:@"%p",   dep.request];
                    SRKRequestOperation * subOp = [processedOperations valueForKey:subIndif];
                    if (subOp) {
                        [op addDependency:subOp];
                    }
                }
                
            }
        }
      
    }
    
    return [processedOperations allValues];
    
    
   _SRKNode * node =  [self name:&processedRequests  requests:requests];
    
    
    
    
    NSLog(@"adasd");
//    for (SRKRequest * req in requests) {
//        
//        if ([processedRequests containsObject:req]) {
//            continue;
//        }
//        [processedRequests addObject:req];
//        if (req.afterRequestsDependencies.count==0) {
//            [independedRequests addObject:req];
//        }
//    }
    
}




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
    
    for (SRKRequestDependency * dep in request.afterRequestsDependencies) {
        [self extractRequestsFromRequest:dep.request result:result fromRequest:request];
    }
    
    [*result addObject:request];
    
}



//-(void)sequence:(NSMutableArray**)processingArray requests:(NSArray*)requests{
//    
//    
//    for
//    
//}







-(_SRKNode*)name:(NSMutableSet **)processedRequests requests:(NSArray*)requests{
    
    _SRKNode * node = [[_SRKNode alloc] init];
    for (SRKRequest * req in requests) {
        
        if ([*processedRequests containsObject:req]) {
            continue;
        }
//        [*processedRequests addObject:req];
      
        if (req.afterRequestsDependencies.count>0) {
 
            NSArray * n =   [self name2:processedRequests fromReq:req];
  
//            [n.requests addObject:req];
            if (n) {
                [[node subnodes] addObjectsFromArray:n];

            }
//        [[node requests] addObject:req];
        }else{
            [[node requests] addObject:req];
        }

        
//        if (req.beforeRequests.count>0) {
//            
//            _SRKNode * n = [self name:processedRequests requests:req.beforeRequests];
//            
//            if (n) {
//                [[node subnodes] addObject:n];
//                
//            }
//        }
        
    }
    
  return node.requests.count==0&&node.subnodes.count==0?nil:node;
}
-(NSArray *)name2:(NSMutableSet **)processedRequests fromReq:(SRKRequest*)req{
    
    NSArray * requestsDependencies = req.afterRequestsDependencies;
    NSMutableArray * result = [[NSMutableArray alloc] init];
    _SRKNode * mainNode = [[_SRKNode alloc] init];
//    [mainNode.requests addObject:req];
//    [result addObject:mainNode];
    for (SRKRequestDependency * reqDpendencie in requestsDependencies) {
        
        if ([*processedRequests containsObject:reqDpendencie.request]) {
            continue;
        }
//        [*processedRequests addObject:reqDpendencie.request];
        
        if (reqDpendencie.request.afterRequestsDependencies.count>0) {
            
            
            _SRKNode * aNode = [[_SRKNode alloc] init];
            [aNode.requests addObject:req];
            
            NSArray * subNode = [self name2:processedRequests  fromReq:reqDpendencie.request];
            _SRKNode * cNode =[[_SRKNode alloc] init];
            [cNode.requests addObject:reqDpendencie.request];
            [[cNode subnodes] addObject:aNode];
            for (_SRKNode * sn in subNode) {
                [[sn subnodes] addObject:cNode];
            }
            
            [result addObjectsFromArray:subNode];
//            if (node) {
//                [node.subnodes addObject:node];
//            }

          
        }else{
             [mainNode.requests addObject:reqDpendencie.request];
        }
        
        
//        if (req.afterRequestsDependencies.count>0) {
//            [self name:processedRequests result:result requests:req.afterRequestsDependencies];
//        }
//        
//        
//        if (req.afterRequestsDependencies.count==0) {
//            
//        }else{
//            
//        }
    }

    if (mainNode.requests.count>0) {
        [result addObject:mainNode];
    }
    
    return result;
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
