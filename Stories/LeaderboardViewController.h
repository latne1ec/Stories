//
//  LeaderboardViewController.h
//  Spotshot
//
//  Created by Evan Latner on 4/17/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "LeaderboardTableCell.h"
#import "ProgressHUD.h"

@interface LeaderboardViewController : UITableViewController

@property (nonatomic, strong) NSArray *users;

- (IBAction)popHome:(id)sender;



@end
