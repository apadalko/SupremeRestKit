//
//  SRKRequestOperation.m
//  Pods
//
//  Created by Alex Padalko on 2/22/17.
//
//

#import "SRKRequestOperation.h"

@interface SRKRequestOperation ()

@property (nonatomic,retain)id data;
@property (nonatomic, getter = isFinished, readwrite)  BOOL finished;
@property (nonatomic, getter = isExecuting, readwrite) BOOL executing;

@end

@implementation SRKRequestOperation

@synthesize finished  = _finished;
@synthesize executing = _executing;
+(instancetype)operationWithMappingTask:(SRKMappingTask *)mappingTask andData:(nonnull id)data complitBlock:(nonnull void (^)(SRKResponse * _Nonnull))completionBlock{
    
   SRKRequestOperation * op = [[self alloc] initWithRequestTask:nil andMappingTask:mappingTask complitBlock:completionBlock] ;
    op.data = data;
    
    return  op;
}
+(instancetype)operationWithRequestTask:(SRKRequestTask *)requestTask andMappingTask:(SRKMappingTask *)mappingTask complitBlock:(void (^)(SRKResponse *))completionBlock{
    
    return [[self alloc] initWithRequestTask:requestTask andMappingTask:mappingTask complitBlock:completionBlock] ;
    
}


-(instancetype)initWithRequestTask:(SRKRequestTask *)requestTask andMappingTask:(SRKMappingTask *)mappingTask complitBlock:(void (^)(SRKResponse *))completionBlock{

    if (self=[super init]) {
        _finished  = NO;
        _executing = NO;
        _requestTask = requestTask;
        _mappingTask = mappingTask;
        self.completionBlock = completionBlock;
    }
    return self;
    
}

- (void)start {
    if ([self isCancelled]) {
        self.finished = YES;
        return;
    }

    
    [self main];
}

-(void)main{
    
    NSArray * workingDepedencies = [[NSArray alloc] initWithArray:self.dependencies];
    for (SRKRequestOperation * dependedOperation in workingDepedencies) {
        
        NSLog(@"aaaa");
        
    }
    
        self.executing = YES;
    if (self.requestTask) {
        [self processAsRequestFirst];
    }else {
        [self processMappingWithData:self.data];
    }
    
}


-(void)processAsRequestFirst{
    _state = SRKOperationStateMakingRequest;
    [self.requestTask start:^( id  _Nullable responseObject, NSError * _Nullable error) {
       
        if (error) {
            SRKResponse * response =   [[SRKResponse alloc] init];
            response.error = error;
            response.success = NO;
            _state = SRKOperationStateFailed;
            self.completionBlock(response);
            self.completionBlock=nil;
            self.finished = YES;
        }else{
            [self processMappingWithData:responseObject];
        }
        
    }];
}
-(void)processMappingWithData:(id)data{
     _state = SRKOperationStateParsing;
    [self.mappingTask startWithData:data complitBlock:^(NSArray<SRKObject *> *objects) {
       
        SRKResponse * response =   [[SRKResponse alloc] init];
        response.rawData = data;
        response.success = YES;
        response.objects = objects;
         _state = SRKOperationStateFinished;
        self.completionBlock(response);
        self.completionBlock=nil;
        self.finished = YES;
        
    }];
}

#pragma mark - NSOperation methods

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    @synchronized(self) {
        return _executing;
    }
}

- (BOOL)isFinished {
    @synchronized(self) {
        return _finished;
    }
}

- (void)setExecuting:(BOOL)executing {
    if (_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        @synchronized(self) {
            _executing = executing;
        }
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)setFinished:(BOOL)finished {
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        @synchronized(self) {
            _finished = finished;
        }
        [self didChangeValueForKey:@"isFinished"];
    }
}

//-(void)dealloc{
//    
////    NSLog(@"DEALLOC");
//}
@end
