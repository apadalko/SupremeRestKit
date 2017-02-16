//
//  SRKResponse.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DSObject/DSObject.h>

@interface SRKResponse : NSObject

@property (nonatomic,retain)NSArray * objects;
-(DSObject*)first;

@property (nonatomic,retain)NSError * error;
@property (nonatomic,retain)id rawData;
@property (nonatomic)BOOL success;

@end
