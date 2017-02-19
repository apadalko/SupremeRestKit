//
//  SRKResponse.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKResponse.h"

@implementation SRKResponse
-(SRKObject*)first{
    return [self.objects firstObject];
}
@end

