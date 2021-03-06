//
//  SRKRequest.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKRequest.h"

#import "SRKRequest_Private.h"
@interface SRKRequest ()

@property (nonatomic,retain)NSMutableArray * _multiparts;
@property (nonatomic,retain)NSMutableArray <SRKRequestDependency*> * _afterRequestsDependencies;
@property (nonatomic,retain)NSMutableArray <SRKRequest*> * _beforeRequests;
@end
@implementation SRKRequest

+(instancetype)GETRequest:(NSString *)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void (^)(SRKResponse *))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodGET url:url urlParams:urlParams mapping:mapping responseBlock:responseBlock
            ];
}

+(instancetype)POSTRequest:(NSString*)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodPOST url:url urlParams:urlParams mapping:mapping responseBlock:responseBlock
            ];
    
}
+(instancetype)DELETERequest:(NSString*)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodDELETE url:url urlParams:urlParams mapping:mapping responseBlock:responseBlock
            ];
    
}
+(instancetype)PUTRequest:(NSString*)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodPUT url:url urlParams:urlParams mapping:mapping responseBlock:responseBlock
            ];
}

-(instancetype)initWithMethod:(SRKRequestMethod)method url:(NSString *)url urlParams:(id)urlParams mapping:(id)mapping responseBlock:(void (^)(SRKResponse *))responseBlock{
    
    if (self=[super init]) {
        self.responseBlock=responseBlock;
        self.method=method;
        self.urlPath=url;
        self.urlParams=urlParams;
        self.mapping=mapping;
    }
    return self;
}

-(instancetype)addResponseBlock:(void(^)(SRKResponse  * response))responseBlock{
    
    self.responseBlock=responseBlock;
    
    return self;
}
-(instancetype)addBodyFromDict:(NSDictionary *)dict{
    
    for (NSString * key in dict) {
        [self addBodyParam:key value:[dict valueForKey:key]];
    }
    return self;
    
}
-(instancetype)addBodyParam:(NSString *)key value:(id)value{
    if (!_body) {
        _body=[[NSMutableDictionary alloc] init];
    }
    [self.body setValue:value forKey:key];
    return self;
}
-(instancetype)addMultipart:(SRKMultipart*)multipart{
    [self._multiparts addObject:multipart];
    
    return self;
}


-(instancetype)inQueueWithName:(NSString *)queueName{
    self.queueName = queueName;
    return self;
}

#pragma mark - private

-(BOOL)allowBodyOrMultipart{
    
    return self.method>SRKRequestMethodHEAD;
}

-(NSString*)HTTPMethod{
    switch (self.method) {
        case SRKRequestMethodGET:
            return  @"GET";;
            break;
        case SRKRequestMethodPOST:
            return  @"POST";
            break;
            
        case SRKRequestMethodPUT:
            return  @"PUT";
            break;
            
        case SRKRequestMethodDELETE:
            return  @"DELETE";
            break;
            
        case SRKRequestMethodPATCH:
            return @"PATCH";
        case SRKRequestMethodHEAD:
            return @"HEAD";
        default:
            return @"GET";
            break;
    }
}

-(NSMutableURLRequest *)generateRequestWithBaseURL:(NSURL*)baseUrl serializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)serializer error:(NSError *__autoreleasing *)error{
//    typedef NSString * (^AFQueryStringSerializationBlock)(NSURLRequest *request, id parameters, NSError *__autoreleasing *error);

//    query = self.queryStringSerialization(request, parameters, &serializationError);
//    mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
//    
    NSURL * url  = [NSURL URLWithString:self.urlPath relativeToURL:baseUrl];
    NSString * finalUrlString = [url absoluteString];
    if (self.urlParams) {
        NSString * paramsString =  AFQueryStringFromParameters(self.urlParams);

        if (paramsString.length>0) {
                    finalUrlString =[NSString stringWithFormat:@"%@%@%@",finalUrlString,url.query ? @"&" : @"?", paramsString];
        }

    }
    
    if (self.multiparts.count>0&&[self allowBodyOrMultipart]) {
       return [serializer multipartFormRequestWithMethod:[self HTTPMethod] URLString:finalUrlString parameters:self.body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           for (SRKMultipart * p in self.multiparts) {
               [formData appendPartWithFileData:[p data] name:[p name] fileName:[p fileName] mimeType:[p mimeType]];
           }
        } error:error];
        
    }else{
        return   [serializer requestWithMethod:[self HTTPMethod] URLString:finalUrlString parameters:[self allowBodyOrMultipart]?self.body:nil error:error];
    }
    
    
    
}

-(NSArray<SRKRequestDependency *> *)afterRequestsDependencies{
    return __afterRequestsDependencies;
}
-(NSArray<SRKRequest *> *)beforeRequests{
    return __beforeRequests;
}

#pragma mark - lazy init
-(NSArray *)multiparts{
    return __multiparts;
}

-(NSMutableArray<SRKRequest *> *)_beforeRequests{
    if (!__beforeRequests) {
        __beforeRequests = [[NSMutableArray alloc] init];
    }
    return __beforeRequests;
}
-(NSMutableArray *)_afterRequests{
    if (!__afterRequestsDependencies) {
        __afterRequestsDependencies=[[NSMutableArray alloc] init];
    }
    return __afterRequestsDependencies;
}

-(NSMutableArray *)_multiparts{
    if (!__multiparts) {
        __multiparts=[[NSMutableArray alloc] init];
    }
    return __multiparts;
}
@end

@implementation SRKRequestDependencyRule



@end

@implementation  SRKRequest (Dependencies)

-(SRKRequest *)then:(SRKRequest *)request{
    return [request after:self];
}
-(SRKRequest *)then:(SRKRequest *)request when:(SRKDependencyRuleType)rule{
    return [request after:self when:rule];
}
-(SRKRequest *)then:(SRKRequest *)request whenBlock:(BOOL (^)(SRKResponse * _Nonnull))ruleBlock{
    return [request after:self whenBlock:ruleBlock];
}

-(instancetype)after:(SRKRequest *)request{
    
    return [self after:request when:SRKDependencyRuleTypeOnSuccess];
}
-(instancetype)after:(SRKRequest *)request when:(SRKDependencyRuleType)rule{
    
    SRKRequestDependencyRule * d = [[SRKRequestDependencyRule alloc] init];
    d.rule=rule;
    d.request=request;
    
    if (![[request _beforeRequests]containsObject:self]) {
        [[request _beforeRequests] addObject:self];

    }
    [[self _afterRequests] addObject:d];
    
    return self;
}
@end



@implementation SRKRequest (DependecyFinder)
-(SRKRequest*)rootRequest{
    
    return  nil;
}
@end
