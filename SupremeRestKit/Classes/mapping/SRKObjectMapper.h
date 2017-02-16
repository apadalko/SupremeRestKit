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


/**
 SRKObjectMapper is used to map data (Dictionary) to a some `DSObject`
 
 you may able to use it in three way:
 i. use instance of SRKObjectMapper with scope (recommended for your code organization)
 ii. use static method +processDataInBackground:forMapping:complitBlock - if doesnt have mapping and just wanna to parse object
 iii. using default mapper after initialization.
 
 @note `DSObject` mapping extentions will use default mapping scope
 */
@interface SRKObjectMapper : NSObject


/**
 Creates a new Object Mapper, with given scope
 @param scope    a valid `SRKMappingScope`, by default it will be a default mapping scope see `SRKMappingScope` +defaultScope
 @return new Object Mapper
 */
-(instancetype)initWithScope:(SRKMappingScope*)scope;

/**
 parsing given data in background
 
 @param data            given data
 @param mapping         some mapping ,  can be: `SRKObjectMapping`, Array<SRKObjectMapping>, String, Array<String>, Dictionary
 @param complitBlock    complitBlock with result array
 
 @note even if u parsing single object - there alway will be an array in complitBlock
 */
-(void)processDataInBackground:(NSDictionary*)data forMapping:(id)maping complitBlock:(void(^)(NSArray * result))complitBlock;







/**
 parsing given data in background with default scope
 
 @param data            given data
 @param mapping         some mapping ,  can be: `SRKObjectMapping`, Array<SRKObjectMapping>, String, Array<String>, Dictionary
 @param complitBlock    complitBlock with result array
 
 @note will use the default mapping scope, if you still want not to use mapping scope at all call +processDataInBackground:withScope:forMapping:complitBlock: with nil value for scope
 @note even if u parsing single object - there alway will be an array in complitBlock
 */
+(void)processDataInBackground:(NSDictionary*)data forMapping:(id)maping complitBlock:(void(^)(NSArray * result))complitBlock;


/**
 parsing given data in background with given scope SCOPE
 
 @param data            given data
 @param scope           a valid `SRKMappingScope`
 @param mapping         some mapping ,  can be: `SRKObjectMapping`, Array<SRKObjectMapping>, String, Array<String>, Dictionary
 @param complitBlock    complitBlock with result array
 
 @note even if u parsing single object - there alway will be an array in complitBlock
 */
+(void)processDataInBackground:(NSDictionary*)data withScope:(SRKMappingScope*)scope forMapping:(id)maping complitBlock:(void(^)(NSArray * result))complitBlock;

@end

