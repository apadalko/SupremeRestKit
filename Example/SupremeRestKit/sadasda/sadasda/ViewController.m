//
//  ViewController.m
//  sadasda
//
//  Created by Alex Padalko on 4/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,retain)UIWebView * wv;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.wv = [[UIWebView alloc] init];
    [self.view addSubview:self.wv];
    [self.wv loadRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:@"http://localhost:443"]]];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self.wv setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+64)];
    [[self.wv scrollView] setContentSize:CGSizeMake ( self.view.frame.size.height, self.view.frame.size.height+128)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
