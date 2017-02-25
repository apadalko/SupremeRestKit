//
//  SimpleDetailsViewController.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/25/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import "SimpleDetailsViewController.h"
#import <SupremeRestKit/SupremeRestKit.h>
@interface SimpleDetailsViewController ()
@property (nonatomic,weak) SRKClient * client;

@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UILabel * bodyLabel;
@property (nonatomic,weak)SRKObject * model;

@property (nonatomic,retain)UIButton * updateButton;
@property (nonatomic,retain)UIButton * backAndUpdateButton;



@end

@implementation SimpleDetailsViewController


-(instancetype)initWithModel:(SRKObject*)model{
    if (self=[super init]) {
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setNumberOfLines:2];
    [self.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:self.titleLabel];
    
    self.bodyLabel = [[UILabel alloc] init];
    [self.bodyLabel setNumberOfLines:0];
    
    [self.view addSubview:self.bodyLabel];
    
    
    
    self.updateButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:self.updateButton];
    [self.updateButton setTitle:@"UPDATE TITLE" forState:UIControlStateNormal];
    [self.updateButton addTarget:self action:@selector(onUpdateButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.backAndUpdateButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:self.backAndUpdateButton];
    [self.backAndUpdateButton setTitle:@"BACK AND UPDATE TITLE" forState:UIControlStateNormal];
    [self.backAndUpdateButton addTarget:self action:@selector(onBackAndUpdateButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [self.client makeRequest:[SRKRequest GETRequest:[NSString stringWithFormat:@"posts/%@",self.model.objectId] urlParams:nil mapping:
                              [[[SRKObjectMapping mappingWithPropertiesArray:@[@"title",@"body"]] setIdentifierKeyPath:@"id"] setStorageName:@"Post"]andResponseBlock:^(SRKResponse * _Nonnull response) {
                                  
                                  
                                  self.titleLabel.text = [response first][@"title"];
                                  self.bodyLabel.text = [response first][@"body"];
                                  [self.view setNeedsDisplay];
                                  
                                  
                              }]];
    // Do any additional setup after loading the view.
}
-(void)onBackAndUpdateButton{
    
    [self.navigationController popViewControllerAnimated:YES];

    
    [self.client makeRequest:[[SRKRequest PUTRequest:[NSString stringWithFormat:@"posts/%@",self.model.objectId] urlParams:nil mapping:
                               [[[SRKObjectMapping mappingWithPropertiesArray:@[@"title",@"body"]] setIdentifierKeyPath:@"id"] setStorageName:@"Post"] andResponseBlock:^(SRKResponse * _Nonnull response) {
                                   
                                   
                                   self.titleLabel.text = [response first][@"title"];
                                   self.bodyLabel.text = [response first][@"body"];
                                   [self.view setNeedsDisplay];
                                   
                                   
                               }] addBodyFromDict:@{@"title":@"new TITILE when BACK"}]];
    
    
}
-(void)onUpdateButton{
    [self.client makeRequest:[[SRKRequest PUTRequest:[NSString stringWithFormat:@"posts/%@",self.model.objectId] urlParams:nil mapping:
                              [[[SRKObjectMapping mappingWithPropertiesArray:@[@"title",@"body"]] setIdentifierKeyPath:@"id"] setStorageName:@"Post"] andResponseBlock:^(SRKResponse * _Nonnull response) {
                                  
                                  
                                  self.titleLabel.text = [response first][@"title"];
                                  self.bodyLabel.text = [response first][@"body"];
                                  [self.view setNeedsDisplay];
                                  
                                  
                              }] addBodyFromDict:@{@"title":@"new TITILE"}]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self.titleLabel setFrame:CGRectMake(16, 84, self.view.frame.size.width-32, 50)];
//    [self.titleLabel sizeToFit];
    
    [self.bodyLabel setFrame:CGRectMake(16, CGRectGetMaxY(self.titleLabel.frame)+10, self.view.frame.size.width-32, self.view.frame.size.height-CGRectGetMaxY(self.titleLabel.frame)-10-20-74-74)];
    
    [self.updateButton setFrame:CGRectMake(16, self.view.frame.size.height-10-64-10-64, self.view.frame.size.width-32, 64)];
    [self.backAndUpdateButton setFrame:CGRectMake(16, self.view.frame.size.height-10-64, self.view.frame.size.width-32, 64)];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(SRKClient *)client{
    if (!_client) {
        _client=[[SRKManager shared] getClientWithName:@"simple"];
    }
    return _client;
}
@end

