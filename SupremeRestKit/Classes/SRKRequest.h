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
    SRKRequestMethodHEAD,
    SRKRequestMethodPOST,
    SRKRequestMethodPUT,
    SRKRequestMethodDELETE,
    SRKRequestMethodPATCH,
    
};
@interface SRKRequest : NSObject



+(instancetype)GETRequest:(NSString*)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;
+(instancetype)POSTRequest:(NSString*)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;
+(instancetype)DELETERequest:(NSString*)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;
+(instancetype)PUTRequest:(NSString*)url urlParams:(id)urlParams mapping:(id)mapping andResponseBlock:(void(^)(SRKResponse  * response))responseBlock;



-(instancetype)initWithMethod:(SRKRequestMethod)method urlParams:(NSString*)urlParams  params:(id)params  mapping:(id)mapping responseBlock:(void(^)(SRKResponse  * response))responseBlock;




-(instancetype)addBodyParam:(NSString *)key value:(id)value;
-(instancetype)addBodyFromDict:(NSDictionary *)dict;


@property (nonatomic,copy)SRKResponseBlock responseBlock;

-(instancetype)addResponseBlock:(void(^)(SRKResponse  * response))responseBlock;

-(instancetype)addMultipart:(SRKMultipart*)multipart;
-(NSArray*)multiparts;

@end
