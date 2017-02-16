//
//  SRKMappingRelation.m
//  Pods
//
//  Created by Alex Padalko on 2/15/17.
//
//

#import "SRKMappingRelation.h"
#import "SRKMappingRelation_Private.h"
@implementation SRKMappingRelation
+(instancetype)realtionWithFromKey:(NSString *)fromKey toKey:(NSString *)toKey mapping:(SRKObjectMapping *)mapping{
    return [[self alloc] initWithFromKey:fromKey toKey:toKey mapping:mapping];
}
-(instancetype)initWithFromKey:(NSString *)fromKey toKey:(NSString *)toKey mapping:(SRKObjectMapping *)mapping{
    if (self=[super init]) {
        self.fromKey=fromKey;
        self.toKey=toKey;
        self.mapping=mapping;
    }
    return self;
}
-(instancetype)addValidationBlock:(BOOL(^)(NSDictionary*data,DSObject * preprocessedObject))validationBlock{
    self.validationBlock=validationBlock;
    return self;
}


@end
#pragma mark - private
@implementation SRKMappingRelation (Private)

+(instancetype)relationWithComplexKey:(NSString*)complexKey{
    
    NSArray * keyParts = [complexKey componentsSeparatedByString:@"->"];
    
    NSString * fromKey = nil;
    NSString * toKey = nil;
    if (keyParts.count>=2){
        
        fromKey = [keyParts firstObject];
        toKey = [keyParts lastObject];
    }else if (keyParts.count==1){
        toKey = [keyParts lastObject];
    }else{
        return nil;
    }
    
    SRKMappingRelation * relation = [[self alloc] init];
    
    relation.fromKey=fromKey;
    relation.toKey=toKey;
    
    return  relation;
    
}


@end
