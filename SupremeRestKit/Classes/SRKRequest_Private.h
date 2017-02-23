//
//  SRKRequest_Private.h
//  Pods
//
//  Created by Alex Padalko on 2/16/17.
//
//
#import "SRKRequest.h"
#import <AFNetworking/AFNetworking.h>
@class SRKRequestDependency;
@interface SRKRequest ()


@property (nonatomic,retain)NSMutableDictionary * body;
@property (nonatomic,retain)id urlParams;
@property (nonatomic,retain)NSString * urlPath;
@property (nonatomic)SRKRequestMethod method;
@property (nonatomic,retain)id mapping; // could be string or dictionary or mapping itself

-(NSString*)HTTPMethod;

-(NSMutableURLRequest *)generateRequestWithBaseURL:(NSURL*)baseUrl serializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)serializer error:(NSError *__autoreleasing *)error;

-(NSArray<SRKRequestDependency*>*)afterRequestsDependencies;
-(NSArray<SRKRequest*>*)beforeRequests;
@end

@interface SRKRequest (DependecyFinder)
-(SRKRequest*)rootRequest;
-(NSInteger)compareToRequest:(SRKRequest*)request;
@end

@interface SRKRequestDependencyRule : SRKDependencyRule
@property(nonatomic,retain)SRKRequest * request;
@end
