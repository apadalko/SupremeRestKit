//
//  SRKDependency.h
//  Pods
//
//  Created by Alex Padalko on 2/23/17.
//
//

#import <Foundation/Foundation.h>
@class SRKResponse;
typedef NS_ENUM(NSInteger,SRKDependencyRuleType){
    
    SRKDependencyRuleTypeOnSuccess,
    SRKDependencyRuleTypeOnError,
    SRKDependencyRuleTypeAlways,
};
typedef BOOL (^SRKDependencyRuleBlock) (SRKResponse  * response);
@interface SRKDependencyRule : NSObject
@property (nonatomic)SRKDependencyRuleType rule;
@property (nonatomic,copy)SRKDependencyRuleBlock ruleBlock;
@end
