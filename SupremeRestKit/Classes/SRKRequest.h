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


@property (nonatomic,copy)SRKResponseBlock responseBlock;

-(instancetype)addResponseBlock:(void(^)(SRKResponse  * response))responseBlock;

-(instancetype)addMultipart:(SRKMultipart*)multipart;
-(nullable NSArray*)multiparts;

@end
NS_ASSUME_NONNULL_END
