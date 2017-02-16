//
//  SRKMappingRelation.m
//  Pods
//
//  Created by Alex Padalko on 2/15/17.
//
//

#import "SRKMappingRelation.h"

@implementation SRKMappingRelation
+(instancetype)realtionWithFromKey:(NSString *)fromKey toKey:(NSString *)toKey mapping:(id)mapping{
    return [[self alloc] initWithFromKey:fromKey toKey:toKey mapping:mapping];
}
-(instancetype)initWithFromKey:(NSString *)fromKey toKey:(NSString *)toKey mapping:(id)mapping{
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
