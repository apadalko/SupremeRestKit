//
//  SRKManager.m
//  Pods
//
//  Created by Alex Padalko on 2/21/17.
//
//

#import "SRKManager.h"
@interface SRKManager ()
@property (atomic,retain)NSMutableDictionary * clinets;
@end
@implementation SRKManager

static SRKManager * sharedManager;
+(instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SRKClient alloc] init];
    });
    
    return sharedManager;
}

-(void)registerClinet:(SRKClient *)clinet withName:(NSString *)name{
    
    [self.clinets setValue:clinet forKey:name];
}
-(SRKClient *)getClinetWithName:(NSString *)name{
    return self.clinets[name];
}

-(NSMutableDictionary *)clinets{
    
    if (!_clinets) {
        _clinets =[[NSMutableDictionary alloc] init];
    }
    return _clinets;
}


@end
