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
#import <SupremeRestKit/SRKObject_.h>
@interface TestObject : SRKObject_

@property (nonatomic,retain)NSString * k;
@end
@implementation TestObject
@synthesize k=_k;


@end

@interface SRKViewController ()
@property (nonatomic,retain)SRKClient * client;
@end

@implementation SRKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
 
    TestObject * t = [TestObject objectWithType:@"sss" andData:@{}];
    t.k = @"asda";
    t[@"k"] = @"asd";
    
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
    
    [self request3];
    
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
        
        [self request3];
        
    }] ;
    
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

-(void)request3{
    
    
    
    SRKObject * localPostObject = [SRKObject objectWithType:@"Post" andData:@{
                                                                              @"localId":@"lalal"
                                                                              
                                                                              }];
    
    NSLog(@"   %@",localPostObject.localId);
    
    SRKObjectMapping * postMapping = [[[SRKObjectMapping mappingWithPropertiesArray:@[
                                                                                     @"id->objectId",
                                                                                     @"userId",
                                                                                     @"title",
                                                                                     @"body"
                                                                                     ]
                                        ] addStorageName:@"Post"] addPermanentProperty:@"localId" value:localPostObject.localId];
    SRKRequest * request = [[SRKRequest POSTRequest:@"posts" urlParams:nil mapping:postMapping andResponseBlock:^(SRKResponse *response) {
        
        
        DSObject * post = [response first];
        
        NSLog(@"%@",localPostObject);
//        post[@"user"][@"username"]=@"somenewusername";
//        
//        [self request2];
        
    }]addBodyFromDict:@{
                              
                              @"title":@"hello",
                              @"body":@"BODYYYYY",
                              @"userId":@"1"
                              
                              }];
        [self.client makeRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
