//
//  SRKObjectManager.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRKProperty.h"
@class SRKObject;
@interface SRKObjectsManager : NSObject
+(SRKObjectsManager*)objectManagerForClass:(Class)clazz;



-(SRKObject*)registerOrGetRecentObjectFromStorage:(SRKObject*)object fetched:(BOOL)fetched;


- (SRKProperty*)propertyForKey:(NSString*)key;
- (NSMethodSignature *)forwardingMethodSignatureForSelector:(SEL)cmd ;
- (BOOL)forwardObjectInvocation:(NSInvocation *)invocation withObject:(SRKObject*)object;

@end

