//
//  SRKRequest.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKRequest.h"
@interface SRKRequest ()

@property (nonatomic,retain)NSMutableArray * _multiparts;


@end
@implementation SRKRequest

+(instancetype)GETRequest:(NSString *)url params:(id)params mapping:(id)mapping andResponseBlock:(void (^)(SRKResponse *))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodGET url:url params:params mapping:mapping responseBlock:responseBlock
            ];
}

+(instancetype)POSTRequest:(NSString*)url params:(id)params mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodPOST url:url params:params mapping:mapping responseBlock:responseBlock
            ];
    
}
+(instancetype)DELETERequest:(NSString*)url params:(id)params mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodDELETE url:url params:params mapping:mapping responseBlock:responseBlock
            ];
    
}
+(instancetype)PUTRequest:(NSString*)url params:(id)params mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock{
    return [[self alloc] initWithMethod:SRKRequestMethodPUT url:url params:params mapping:mapping responseBlock:responseBlock
            ];
}

-(instancetype)initWithMethod:(SRKRequestMethod)method url:(NSString *)url params:(id)params mapping:(id)mapping responseBlock:(void (^)(SRKResponse *))responseBlock{
    
    if (self=[super init]) {
        self.responseBlock=responseBlock;
        self.method=method;
        self.urlPath=url;
        self.params=params;
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
-(NSArray *)multiparts{
    return __multiparts;
}

-(NSMutableArray *)_multiparts{
    if (!__multiparts) {
        __multiparts=[[NSMutableArray alloc] init];
    }
    return __multiparts;
}
@end
