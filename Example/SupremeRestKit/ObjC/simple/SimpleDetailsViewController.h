//
//  SimpleDetailsViewController.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/25/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SRKObject;
@interface SimpleDetailsViewController : UIViewController
-(instancetype)initWithModel:(SRKObject*)model;
@end
