//
//  SRKResponse.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRKObject.h"

@interface SRKResponse : NSObject

@property (nonatomic,retain,nullable)NSArray * objects;
-(nullable SRKObject*)first;

@property (nonatomic,retain,nullable)NSError * error;
@property (nonatomic,retain,nullable)id rawData;
@property (nonatomic)BOOL success;

@end
