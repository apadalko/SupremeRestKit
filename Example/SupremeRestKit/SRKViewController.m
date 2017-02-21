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

@interface User : SRKObject
@property (nonatomic,retain) NSString * username;
@end
@implementation User
@dynamic username;
@end
@interface Article :SRKObject
@property (nonatomic,retain) User * fromUser;
@property (nonatomic,retain)NSString * title;
@property (nonatomic,retain)NSString * text;
@property (nonatomic,retain)NSString * ownProperty;
@end
@implementation Article
@dynamic title,text,fromUser;
@dynamic ownProperty;

-(void)setOwnProperty:(NSString *)ownProperty{
    [super setObject:ownProperty forKey:@"ownProperty"];
}
-(NSString *)ownProperty{
    return [super objectForKey:@"ownProperty"];
}
@end


@interface TestObject : SRKObject

@property (nonatomic,retain)NSString * k;

@property (nonatomic,retain)NSString * d;
@end
@implementation TestObject

-(void)setK:(NSString *)k{
    [super setObject:k forKey:@"k"];
}

@end

@interface SRKViewController ()
@property (nonatomic,retain)SRKClient * client;
@end

@implementation SRKViewController


-(void)codeForReadMe{
    
    [SRKObject objectWithData:@{}];
    
    Article * art = [Article objectWithData:@{}];
    art[@"ownProperty"] = @"asdasd";
    NSLog(@"art");
    
    //define client
    SRKClient * client = [[SRKClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.awesomeapp.com/v1"]];
    //define mapping
    
    SRKObjectMapping * mapping = [SRKObjectMapping mappingWithPropertiesArray:@[@"title"]];
    //add id for mapping
    [mapping setIdentifierKeyPath:@"id"];
    /*set RAM storage name where you will store this type of object,
     not needed if you are using subclases**/
    [mapping setStorageName:@"Article"];
    //if you have a nested objects - add a relation with mapping
    SRKObjectMapping * nestedMapping = [SRKObjectMapping mappingWithProperties:
                                        @{
                                          @"id":@"objectId",// objectId - default indifiter key
                                          @"username":@"username"
                                          }];
    //RAM Storage Name for nested object
    [nestedMapping setStorageName:@"User"];
    //adding relation
    [mapping addRelationFromKey:@"user" toKey:@"fromUser" relationMapping:nestedMapping];
// or   [mapping addRelation:[SRKMappingRelation realtionWithFromKey:@"user" toKey:@"fromUser" mapping:mapping]];
    
    
    //create request
    SRKRequest * request = [SRKRequest GETRequest:@"articles" urlParams:nil mapping:mapping andResponseBlock:^(SRKResponse *response) {
        
    }];
    //make request
    [client makeRequest:request];
    
    
    
    [client makeRequest:[SRKRequest GETRequest:@"articles" urlParams:nil mapping:[[[SRKObjectMapping mappingWithPropertiesArray:@[@"title"]] setIdentifierKeyPath:@"id"] setStorageName:@"Article"] andResponseBlock:^(SRKResponse *response) {
        NSArray * articlesList = [response objects];
        //articlesList have two objects type of SRKObject
        NSString * firstTitle = articlesList.firstObject[@"title"];
    }]];
    
    
    
    ///
    SRKObjectMapping * articleMapping = [Article mappingWithProperties:@{@"title":@"title",@"id":@"objectId"}];
    SRKObjectMapping * userMapping = [User mappingWithPropertiesArray:@[@"username"] indfiterKeyPath:@"id"];
    [articleMapping addRelationFromKey:@"user" toKey:@"fromUser" relationMapping:userMapping];
    
    
    
//    [client makeRequest:[SRKRequest GETRequest:@"articles" urlParams:nil mapping:[[[SRKObjectMapping mappingWithPropertiesArray:@[@"title",@"text"]] addObjectIdentifierKeyPath:@"id"] addRelationFromKey:@"user" toKey:@"fromUser" relationMapping:[[SRKObjectMapping mappingWithProperties:@{@"username":@"username",@"id":@"objectId"}] addObjectIdentifierKeyPath:@"id"]] andResponseBlock:^(SRKResponse *response) {
//        NSArray * fullArticleObject = [response first];
//      
//        [[articlesList firstObject] isEqual:fullArticleObject] // returns true
//        [articlesList firstObject][@"user"] // as well is object in array is the same - it have user
//        [articlesList firstObject][@"title"] //
//        
//    }]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
 
    TestObject * t = [TestObject objectWithType:@"sss" andData:@{}];
    t.k = @"asda";
    t[@"k"] = @"asd";
     t.d = @"asda2";
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
    
//    [self codeForReadMe];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)request1{
    
//    [SRKObjectMapping map]
    
//    SRKObjectMapping * postMapping = [[SRKObjectMapping mappingWithPropertiesArray:@[
//                                                                                     @"id->objectId",
//                                                                                     @"userId",
//                                                                                     @"title",
//                                                                                     @"body"]] addStorageName:@"Post"];
//    SRKObjectMapping * userMapping = [[SRKObjectMapping mappingWithProperties:@{
//                                                                                @"userId":@"objectId"
//                                                                                } andKeyPath:nil] addStorageName:@"User"];
//    
//    
////    [postMapping addRelation:nil toKey:@"user" relationMapping:userMapping];
////    [postMapping addRelation:nil rightKey:@"user" relationMapping:userMapping];
////    [postMapping addRelation:nil rightKey:@"user" relation:userMapping];
//    
//
//    SRKRequest * request = [SRKRequest GETRequest:@"posts/1" urlParams:nil mapping:postMapping andResponseBlock:^(SRKResponse *response) {
//        
//        
//        DSObject * post = [response first];
//        post[@"user"][@"username"]=@"somenewusername";
//        
//        [self request3];
//        
//    }] ;
//    
//    [self.client makeRequest:request];
}
-(void)request2{
//    SRKObjectMapping * postMapping = [[[SRKObjectMapping mappingWithPropertiesArray:@[
//                                                                                     @"id",
//                                                                                   ]] addStorageName:@"Post"] addObjectIdentifierKeyPath:@"id"];
//    
//    SRKRequest * request = [SRKRequest GETRequest:@"posts/1" urlParams:nil mapping:postMapping andResponseBlock:^(SRKResponse *response) {
//        
//        NSLog(@"???");
//    }];
//        [self.client makeRequest:request];
}

-(void)request3{
//    
//    
//    
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
                                        ] setStorageName:@"Post"] addPermanentProperty:@"localId" value:localPostObject.localId];
    SRKRequest * request = [[SRKRequest POSTRequest:@"posts" urlParams:nil mapping:postMapping andResponseBlock:^(SRKResponse *response) {
        
        
        SRKObject * post = [response first];
        
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
