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
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

-(void)registerClient:(SRKClient *)client withName:(NSString *)name{
    
    [self.clinets setValue:client forKey:name];
}
-(SRKClient *)getClientWithName:(NSString *)name{
    return self.clinets[name];
}

-(NSMutableDictionary *)clinets{
    
    if (!_clinets) {
        _clinets =[[NSMutableDictionary alloc] init];
    }
    return _clinets;
}


@end
