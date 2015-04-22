//
//  StoriesTableViewController.h
//  Stories
//
//  Created by Evan Latner on 2/27/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTableCell.h"
#import "FeaturedTableCell.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"
#import "KASlideShow.h"
#import "SDWebImageManager.h"
#import "ViewVideoViewController.h"
#import "ViewHomeVideosViewController.h"
#import "SignupViewController.h"
#import "LeaderboardViewController.h"

@class MainStoriesViewController;

@interface StoriesTableViewController : UITableViewController <CLLocationManagerDelegate, UISearchBarDelegate>


//@property (nonatomic, strong) NSArray *stories;
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, strong) PFObject *home;
@property (nonatomic, strong) PFGeoPoint *userLocation;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *score;
@property (nonatomic, strong) UILongPressGestureRecognizer *longTap;
//@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *daHomeName;
@property (nonatomic, strong) MainStoriesViewController *storyOne;
@property (nonatomic, strong) PFObject *searchedStory;
@property (nonatomic, readonly) NSUInteger currentIndex;

@property (nonatomic, strong) UITapGestureRecognizer *tapp;



@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;





@end
