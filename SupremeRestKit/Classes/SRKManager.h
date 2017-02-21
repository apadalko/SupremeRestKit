//
//  SRKManager.h
//  Pods
//
//  Created by Alex Padalko on 2/21/17.
//
//

#import <Foundation/Foundation.h>
#import "SRKClient.h"
NS_ASSUME_NONNULL_BEGIN
@interface SRKManager : NSObject

+(instancetype)shared;

-(void)registerClient:(SRKClient*)clinet withName:(NSString*)name;
-(nullable SRKClient*)getClientWithName:(NSString*)name;

@end
NS_ASSUME_NONNULL_END
