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

-(void)registerClinet:(SRKClient*)clinet withName:(NSString*)name;
-(SRKClient*)getClinetWithName:(NSString*)name;

@end
NS_ASSUME_NONNULL_END
