//
//  SRKRequest_Private.h
//  Pods
//
//  Created by Alex Padalko on 2/16/17.
//
//
#import "SRKRequest.h"
#import <AFNetworking/AFNetworking.h>

@interface SRKRequest ()


@property (nonatomic,retain)NSMutableDictionary * body;
@property (nonatomic,retain)id urlParams;
@property (nonatomic,retain)NSString * urlPath;
@property (nonatomic)SRKRequestMethod method;
@property (nonatomic,retain)id mapping; // could be string or dictionary or mapping itself

-(NSString*)HTTPMethod;

-(NSMutableURLRequest *)generateRequestWithBaseURL:(NSURL*)baseUrl serializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)serializer error:(NSError *__autoreleasing *)error;
@end
