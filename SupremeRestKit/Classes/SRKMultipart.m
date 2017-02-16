//
//  SRKMultipart.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "SRKMultipart.h"

@implementation SRKMultipart
+(instancetype)multiPartWithDictionarty:(NSDictionary*)dict name:(NSString*)name fileName:(NSString*)fileName{
    
    if (dict) {
        return [self multiPartWithData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil] name:name fileName:fileName amdMimeType:@"application/json"];
    }else return nil;
    
}
+(instancetype)multiPartWithArray:(NSArray*)array name:(NSString*)name fileName:(NSString*)fileName{
    
    if (array) {
        return [self multiPartWithData:[NSJSONSerialization dataWithJSONObject:array options:0 error:nil] name:name fileName:fileName amdMimeType:@"application/json"];
    }else return nil;
    
}
+(instancetype)multiPartWithData:(NSData*)data name:(NSString*)name fileName:(NSString*)fileName amdMimeType:(NSString*)mimeType{
    
    SRKMultipart * multiPart  = [[self alloc] init];
    multiPart.data=data;
    multiPart.name=name;
    multiPart.fileName=fileName;
    multiPart.mimeType=mimeType;
    
    return multiPart;
    
}
@end
