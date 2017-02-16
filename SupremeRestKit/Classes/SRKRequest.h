//
//  SRKRequest.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRKResponse.h"
#import "SRKMultipart.h"
typedef void (^SRKResponseBlock) (SRKResponse  * response);
typedef NS_ENUM(NSInteger,SRKRequestMethod){
    
    SRKRequestMethodGET,
    SRKRequestMethodPOST,
    SRKRequestMethodPUT,
    SRKRequestMethodDELETE,
    
};
@interface SRKRequest : NSObject


+(instancetype)GETRequest:(NSString*)url params:(id)params mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;
+(instancetype)POSTRequest:(NSString*)url params:(id)params mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;
+(instancetype)DELETERequest:(NSString*)url params:(id)params mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;

+(instancetype)PUTRequest:(NSString*)url params:(id)params mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;



-(instancetype)initWithMethod:(SRKRequestMethod)method url:(NSString*)url  params:(id)params  mapping:(id)mapping responseBlock:(void(^)(SRKResponse  * response))responseBlock;


@property (nonatomic,retain)NSMutableDictionary * body;
@property (nonatomic,retain)id params;
@property (nonatomic,retain)NSString * urlPath;
@property (nonatomic)SRKRequestMethod method;
@property (nonatomic,retain)id mapping; // could be string or dictionary or mapping itself

-(instancetype)addBodyParam:(NSString *)key value:(id)value;


-(instancetype)addBodyFromDict:(NSDictionary *)dict;


@property (nonatomic,copy)SRKResponseBlock responseBlock;

-(instancetype)addResponseBlock:(void(^)(SRKResponse  * response))responseBlock;

-(instancetype)addMultipart:(SRKMultipart*)multipart;
-(NSArray*)multiparts;

@end
