//
//  SRKMultipart.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRKMultipart : NSObject
+(instancetype)multiPartWithArray:(NSArray*)array name:(NSString*)name fileName:(NSString*)fileName;
+(instancetype)multiPartWithDictionarty:(NSDictionary*)dict name:(NSString*)name fileName:(NSString*)fileName;
+(instancetype)multiPartWithData:(NSData*)data name:(NSString*)name fileName:(NSString*)fileName amdMimeType:(NSString*)mimeType;
@property (nonatomic,retain)NSString * name;
@property (nonatomic,retain)NSString * mimeType;
@property (nonatomic,retain)NSString * fileName;
@property (nonatomic,retain)NSData * data;
@end
