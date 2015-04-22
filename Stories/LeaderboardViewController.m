//
//  LeaderboardViewController.m
//  Spotshot
//
//  Created by Evan Latner on 4/17/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "LeaderboardViewController.h"

@interface LeaderboardViewController ()

@end

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        
        NSLog(@"iPhone 4 or 5");
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AvenirNext-DemiBold" size:23], NSFontAttributeName, nil]];
        
        
        
    }
    
    else {
        
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AvenirNext-DemiBold" size:24], NSFontAttributeName, nil]];
        
    }

    
    
    
    self.navigationItem.hidesBackButton = YES;
    self.tableView.tableFooterView = [UIView new];
    [self queryForUsers];
    
}


-(void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        
        NSLog(@"iPhone 4 or 5");
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AvenirNext-DemiBold" size:25], NSFontAttributeName, nil]];
        
        
        
    }
    
    else {
        
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AvenirNext-DemiBold" size:26], NSFontAttributeName, nil]];
        
    }

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    LeaderboardTableCell *cell = (LeaderboardTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LeaderboardTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    PFObject *user = [self.users objectAtIndex:indexPath.row];
    cell.username.text = [user objectForKey:@"username"];
    cell.userScore.text = [formatter stringFromNumber:[user objectForKey:@"userScore"]];
    
    
    PFFile *homeImage = [user objectForKey:@"thumbnailPic"];
    PFImageView *ImageView = (PFImageView*)cell.userPic;
    ImageView.image = [UIImage imageNamed:@"placeholder"];
    ImageView.file = homeImage;
    [ImageView loadInBackground];
    
    cell.userPic.layer.cornerRadius = cell.userPic.frame.size.width / 2;
    cell.userPic.clipsToBounds = YES;

    
    
    // Configure the cell...
    
    return cell;
}

-(void)queryForUsers {
    
    [ProgressHUD show:nil Interaction:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"userStatus" equalTo:@"registered"];
    [query orderByDescending:@"userScore"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        if (error) {
            
            NSLog(@"error");
            [ProgressHUD showError:@"Network Error"];
            
        }
        
        else {
        [ProgressHUD dismiss];
        self.users = objects;
        [self.tableView reloadData];
        }
    }];
}

 
- (IBAction)popHome:(id)sender {
    
    [self.navigationController popViewControllerAnimated:NO];
    
}
@end
