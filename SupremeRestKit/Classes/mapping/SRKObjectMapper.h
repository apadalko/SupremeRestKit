//
//  SRKObjectMapper.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRKObjectMapping.h"
#import "SRKMappingScope.h"
@class SRKObject;
@interface SRKObjectMapper : NSObject
-(instancetype)initWithScope:(SRKMappingScope*)scope;
-(void)processData:(NSDictionary*)data forMapping:(id)maping complitBlock:(void(^)(NSArray * result))complitBlock;

@end
