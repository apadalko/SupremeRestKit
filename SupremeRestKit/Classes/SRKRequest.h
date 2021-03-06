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
#import "SRKDependencyRule.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^SRKResponseBlock) (SRKResponse  * response);

typedef NS_ENUM(NSInteger,SRKRequestMethod){
    
    SRKRequestMethodGET,
    SRKRequestMethodHEAD,
    SRKRequestMethodPOST,
    SRKRequestMethodPUT,
    SRKRequestMethodDELETE,
    SRKRequestMethodPATCH,
    
};



@interface SRKRequest : NSObject



+( instancetype)GETRequest:(nullable NSString* )url urlParams:(nullable id)urlParams mapping:(nullable id)mapping andResponseBlock:(void(^)(SRKResponse  *  response))responseBlock;
+(  instancetype)POSTRequest:(nullable NSString*)url urlParams:(nullable id)urlParams mapping:(nullable id)mapping andResponseBlock:(void(^)(SRKResponse  *  response))responseBlock;
+(  instancetype)DELETERequest:(nullable NSString*)url urlParams:(nullable id)urlParams mapping:(nullable id)mapping andResponseBlock:(void(^)(SRKResponse  *  response))responseBlock;
+(  instancetype)PUTRequest:(nullable NSString*)url urlParams:(nullable id)urlParams mapping:(nullable id)mapping andResponseBlock:(void(^)(SRKResponse  *  response))responseBlock;



-(instancetype)initWithMethod:(SRKRequestMethod)method urlParams:(nullable NSString*)urlParams  params:(nullable id)params  mapping:(nullable id)mapping responseBlock:(void(^)(SRKResponse  * response))responseBlock;




-(instancetype)addBodyParam:(NSString *)key value:(id)value;
-(instancetype)addBodyFromDict:(NSDictionary *)dict;
-(instancetype)inQueueWithName:(NSString*)queueName;


@property (nonatomic,copy)SRKResponseBlock responseBlock;

-(instancetype)addResponseBlock:(void(^)(SRKResponse  * response))responseBlock;

-(instancetype)addMultipart:(SRKMultipart*)multipart;
-(nullable NSArray*)multiparts;


@property (nonatomic,retain)NSString * queueName;

@end

@interface SRKRequest (Dependencies)

-(instancetype)after:(SRKRequest*)request;
-(instancetype)after:(SRKRequest*)request when:(SRKDependencyRuleType)rule;
-(instancetype)after:(SRKRequest*)request whenBlock:( BOOL (^) (SRKResponse * response) )ruleBlock;

-(SRKRequest*)then:(SRKRequest*)request;
-(SRKRequest*)then:(SRKRequest*)request when:(SRKDependencyRuleType)rule;
-(SRKRequest*)then:(SRKRequest*)request whenBlock:( BOOL (^) (SRKResponse * response) )ruleBlock;



@end

NS_ASSUME_NONNULL_END
