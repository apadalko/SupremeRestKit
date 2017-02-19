//
//  SRKObject_Private.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/18/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import "SRKObject.h"

@interface SRKObject ()


-(instancetype)syncObject:(BOOL)isFetched associatedObjects:(NSArray*)objects;
@end
