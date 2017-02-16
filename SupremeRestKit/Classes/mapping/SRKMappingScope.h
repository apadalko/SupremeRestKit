//
//  SRKMappingScope.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRKObjectMapping.h"
@interface SRKMappingScope : NSObject



-(instancetype)initWithFile:(NSString*)filepath;
-(instancetype)initWithDictionary:(NSDictionary*)data;

-(instancetype)addMapping:(SRKObjectMapping*)mapping withName:(NSString*)name;

-(NSArray<SRKObjectMapping*>*)getObjectMappings:(id)mapping;
@end

