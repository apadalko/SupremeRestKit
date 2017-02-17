//
//  SRKViewController.m
//  SupremeRestKit
//
//  Created by apadalko on 02/15/2017.
//  Copyright (c) 2017 apadalko. All rights reserved.
//

#import "SRKViewController.h"
#import <SupremeRestKit/SRKObjectMapping.h>
#import <SupremeRestKit/SRKClient.h>

@interface SRKViewController ()
@property (nonatomic,retain)SRKClient * client;
@end

@implementation SRKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.client  = [[SRKClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://jsonplaceholder.typicode.com"]];
//        SRKMappingScope * scope = [[SRKMappingScope alloc] initWithFile:@"gm_v2_mapping"];
//    SRKMappingRelation * r;
//
//  SRKObjectMapping * act =  [SRKObjectMapping mappingExtends:@"activity"];
//    
//    [act addRelation:@"lalaUser" toKey:@"blaUser" relationMapping:[SRKObjectMapping mappingExtends:@"user"]];
//    
//    
//   id m =  [scope getObjectMappings:act];
//
//    
//    m = [scope getObjectMappings:@"comments/following"];
    
    [self request1];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)request1{
    
//    [SRKObjectMapping map]
    
    SRKObjectMapping * postMapping = [[SRKObjectMapping mappingWithPropertiesArray:@[
                                                                                     @"id->objectId",
                                                                                     @"userId",
                                                                                     @"title",
                                                                                     @"body"]] addStorageName:@"Post"];
    SRKObjectMapping * userMapping = [[SRKObjectMapping mappingWithProperties:@{
                                                                                @"userId":@"objectId"
                                                                                } andKeyPath:nil] addStorageName:@"User"];
    
    
    [postMapping addRelation:nil toKey:@"user" relationMapping:userMapping];
//    [postMapping addRelation:nil rightKey:@"user" relationMapping:userMapping];
//    [postMapping addRelation:nil rightKey:@"user" relation:userMapping];
    
    
    SRKRequest * request = [SRKRequest GETRequest:@"posts/1" urlParams:nil mapping:postMapping andResponseBlock:^(SRKResponse *response) {
        
        
        DSObject * post = [response first];
        post[@"user"][@"username"]=@"somenewusername";
        
        [self request2];
        
    }];
    
    [self.client makeRequest:request];
}
-(void)request2{
    SRKObjectMapping * postMapping = [[[SRKObjectMapping mappingWithPropertiesArray:@[
                                                                                     @"id",
                                                                                   ]] addStorageName:@"Post"] addObjectIdentifierKeyPath:@"id"];
    
    SRKRequest * request = [SRKRequest GETRequest:@"posts/1" urlParams:nil mapping:postMapping andResponseBlock:^(SRKResponse *response) {
        
        NSLog(@"???");
    }];
        [self.client makeRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
