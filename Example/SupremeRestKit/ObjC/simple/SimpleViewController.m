//
//  SimpleViewController.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/23/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import "SimpleViewController.h"
#import <SupremeRestKit/SupremeRestKit.h>
#import "SimpleDetailsViewController.h"


@interface SimpleViewController (Table)<UITableViewDelegate,UITableViewDataSource>
-(void)generateTableView;
@end

@interface SimpleViewController ()
@property (nonatomic,retain)NSArray * items;
@property (nonatomic,weak) SRKClient * client;

@property (nonatomic)NSInteger step;
@property (nonatomic)NSInteger count;
@property (nonatomic,retain) UITableView * resultsTableView;

@end

@implementation SimpleViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.resultsTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SRKClient * fluidClient = [[SRKManager shared] getClientWithName:@"fluid"];
    
    [[fluidClient requestSerialized] setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
    [[fluidClient requestSerialized] setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];

    [[fluidClient requestSerialized] setValue:@"ru" forHTTPHeaderField:@"Accept-Language"];

    [[fluidClient requestSerialized] setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];

    [[fluidClient requestSerialized] setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];

       [[fluidClient requestSerialized] setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
       [[fluidClient requestSerialized] setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Accept"];
       [[fluidClient requestSerialized] setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_1 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Mobile/14A403" forHTTPHeaderField:@"User-Agent"];
       [[fluidClient requestSerialized] setValue:@"b5a638e4-def8-4403-9555-c6f287b9e9dd" forHTTPHeaderField:@"X-Titanium-Id"];
    
    
    self.count=0;
    self.step=0;
    [self makeRequest];

//    [fluidClient makeRequest:[SRKRequest GETRequest:@"items/7267" urlParams:nil mapping:nil andResponseBlock:^(SRKResponse * _Nonnull response) {
//        
//        NSLog(@"%@",response);
//        
//        
//    }]];
    
    return;
    
    
    
    
    [self generateTableView];
    
    [self.client makeRequest:[SRKRequest GETRequest:@"posts" urlParams:nil mapping:
                              [[[SRKObjectMapping mappingWithPropertiesArray:@[@"title",@"body"]] setIdentifierKeyPath:@"id"] setStorageName:@"Post"] andResponseBlock:^(SRKResponse * _Nonnull response) {
                                  
                                  
                                  self.items =[response objects];
                                  [self.resultsTableView reloadData];
                                  NSLog(@"%@",@"asdas");
                                  
                                  
                              }]];
    
    // Do any additional setup after loading the view.
}

-(void)makeRequest{
    if (self.step>=100000) {
                    NSLog(@"-------");
                    NSLog(@"TOTAL COUNT: %ld",self.count);
        return;
    }
    [[[SRKManager shared] getClientWithName:@"fluid"] makeRequest:[SRKRequest GETRequest:[NSString stringWithFormat:@"users/%ld",self.step] urlParams:nil mapping:nil andResponseBlock:^(SRKResponse * _Nonnull response) {
        
        NSLog(@"%@",response);
        
        if (response.success) {
                 NSLog(@"SUCCESS");
            self.count++;
            NSLog(@"TOTAL COUNT: %ld",self.count);
        
        }else{
            NSLog(@"FAIL");
        }
        self.step++;
        [self makeRequest];
        
    }]];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.resultsTableView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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




#pragma mark - table


@interface SimpleTableViewCell : UITableViewCell


@end
@implementation SimpleTableViewCell

-(void)setModel:(SRKObject*)model{
    self.textLabel.text = model[@"title"];
    self.detailTextLabel.text = model[@"body"];
}

@end

@implementation SimpleViewController (Table)

-(void)generateTableView{
    self.resultsTableView = [[UITableView alloc] init];
    [self.resultsTableView setDataSource:self];
    [self.resultsTableView setDelegate:self];
    [self.view addSubview:self.resultsTableView];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController pushViewController:[[SimpleDetailsViewController alloc] initWithModel:self.items[indexPath.row]] animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString * indif = @"cell_indif";
    
    SimpleTableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:indif];
    
    if (!cell) {
        cell = [[SimpleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indif];
    }
    [cell setModel:self.items[indexPath.row]];
    
    return cell;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0;
}



@end
