//
//  HomeTableViewController.m
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "HomeTableViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

//@synthesize imagePicker;
@synthesize myCollegeCell, topRatedCell, secondFeaturedStoryCell;
@synthesize image;
@synthesize myCollegeStory;
@synthesize allCollegesPic;
@synthesize thePhotoCaption;
@synthesize featuredStoryName;
@synthesize secondFeaturedStoryName, secondFeaturedPic;
@synthesize imageQuery;




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:0.953 green:0.953 blue:0.953 alpha:1];
    
    self.navigationController.toolbar.translucent = YES;
    
    
    
    self.navigationController.navigationBar.translucent = NO;
    
    
    
    
    if([PFUser currentUser]) {
        
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            
            if (error) {
                
                //NSLog(@"%@", error);
                
            }
            
            if (!error) {
            //NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            
            self.userLocation = geoPoint;
            
                [self queryForTable];
                
                
                
            }
            
        }];
        
    }
    
    else {
        
        NSLog(@"somethings wrong");
        
    }


    
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.toolbarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
        
    
    self.tableView.tableFooterView = [UIView new];
    
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipe.delegate = (id)self;
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipe];
    
    
    
    
    const NSTimeInterval configRefreshInterval = 12.0 * 60.0 * 60.0;
    static NSDate *lastFetchedDate;
    
    if (lastFetchedDate == nil ||
        [lastFetchedDate timeIntervalSinceNow] * -1.0 > configRefreshInterval) {
        [PFConfig getConfigInBackgroundWithBlock:nil];
        lastFetchedDate = [NSDate date];
    }
    
    
    
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        NSString *featuredStory = config[@"featuredStory"];
        PFFile *featuredPic = config[@"featuredStoryPic"];
        NSString *secondFeaturedStory = config[@"featuredStoryTwo"];
        PFFile *secondFeaturedStoryPic = config[@"featuredStoryTwoPic"];
        
        
        featuredStoryName.text = featuredStory;
        secondFeaturedStoryName.text = secondFeaturedStory;

        [featuredPic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                NSLog(@"CONFIG");
                UIImage *daImageTwo = [UIImage imageWithData:data];
                allCollegesPic.layer.cornerRadius = allCollegesPic.frame.size.width / 2;
                allCollegesPic.clipsToBounds = YES;
                allCollegesPic.image = daImageTwo;
                [self.tableView reloadData];
                
            }
        }];
        
        [secondFeaturedStoryPic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                UIImage *daImageThree = [UIImage imageWithData:data];
                secondFeaturedPic.layer.cornerRadius = allCollegesPic.frame.size.width / 2;
                secondFeaturedPic.clipsToBounds = YES;
                secondFeaturedPic.image = daImageThree;
                [self.tableView reloadData];
                
            }
        }];
        
        
    }];

    
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.translucent = NO;
    
    [super viewWillAppear:animated];
    
   // NSLog(@"view appeared");

    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO];
    
    
    //Set Story Images
    myCollegeStory.layer.cornerRadius = myCollegeStory.frame.size.width / 2;
    myCollegeStory.clipsToBounds = YES;

    
//       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
}

-(void)appClosed{
    
    // code that puts the view on top
    NSLog(@"app became active");
    
    
     [self.navigationController popToRootViewControllerAnimated:NO];
 
    
    
}


- (PFQuery *)queryForTable {
    
    if (!self.userLocation) {
        NSLog(@"nilllll");
        
        return nil;
    }

    
    
    [ProgressHUD show:nil Interaction:NO];
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    //[query whereKey:@"postLocation" nearGeoPoint:self.userLocation withinMiles:7];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            
            NSLog(@"%@", error);
            
            
        }
        
        if (object == nil) {
            
            [ProgressHUD dismiss];
            
            myCollegeStory.image = [UIImage imageNamed:@"placeholder.png"];
            
        }
        
        else {
            
            
            PFFile *file = [object objectForKey:@"imageFile"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    
                    [ProgressHUD dismiss];
                    UIImage *daImage = [UIImage imageWithData:data];
                    myCollegeStory.image = daImage;
                    [self.tableView reloadData];
                    
                    //[self queryForImages];
                    
                }
            }];
            
            
        }
    }];

 
    
    return nil;
    
}


- (void) handleSwipe:(id)sender {
    
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;

    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        
        
    }
}





#pragma mark - Table view data source



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor colorWithRed:249/255.0f green:249/255.0f blue:249/255.0f alpha:1.0f]];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14]];
    
    
    //[[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:0.322 green:0.318 blue:0.318 alpha:1]];
    
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:0.867 green:0.243 blue:0.243 alpha:1]];
    
    
    if (section == 0) {
        
        return @"Home";
    }
    if (section == 1) {
        
        return @"Featured";
        
    }
    return nil;
}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

        
    if (section == 0) {
        
        return 1;
    }
    
    if (section == 1) {
        return 2;
    }
    
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        
        
        
        return myCollegeCell;
    }
    
    
    if (indexPath.section == 1) {
    
        if (indexPath.row == 0) {
            
        
        return topRatedCell;
        }
        
        if (indexPath.row == 1) {
            
            return secondFeaturedStoryCell;
        }
    }

    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    
    if (cell == myCollegeCell) {
        
        //show my college pics
        
        [self showMyCollegePics];
        
    }
    
    
    if (cell == topRatedCell) {
        
        
        [self showFirstFeaturedStory];
        
        
    }
    
    if (cell == secondFeaturedStoryCell) {

        [self showSecondFeaturedStory];
        
    }
    
}

-(void)showMyCollegePics {
    
    NSLog(@"lalalla");
    
    MainStoriesViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainStories"];
    //svc.photos = _photos;
    mvc.userLocation = self.userLocation;
    [self.navigationController pushViewController:mvc animated:NO];
    
}

-(void)showFirstFeaturedStory {
    
    NSLog(@"lalalla");
    
    FirstFeaturedViewController *ffvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstFeatured"];
    //svc.photos = _photos;
    [self.navigationController pushViewController:ffvc animated:NO];
    
}

-(void)showSecondFeaturedStory {
    
    NSLog(@"lalalla");
    
    SecondFeaturedViewController *sfvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondFeatured"];
    //svc.photos = _photos;
    [self.navigationController pushViewController:sfvc animated:NO];
    
}









- (IBAction)scorePopup:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Spotshot" message:@"This is Spotshot v1.0. An update will be released soon with more features. Tweet at us @getspotshot for support or tell us what you'd like to see in the next update." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alertView show];
    
    
}


- (IBAction)showCamera:(id)sender {
    
    
    [self.navigationController popToRootViewControllerAnimated:NO];

    
}


///************ Start downloading images

- (PFQuery *)queryForImages {
    
    if (!self.userLocation) {
        NSLog(@"nilllll");
        
        return nil;
    }
    
    NSLog(@"Refreshing");
    //PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    
    self.imageQuery = [PFQuery queryWithClassName:@"UserPhoto"];
    
    [imageQuery setLimit: 100];
    [imageQuery orderByAscending:@"createdAt"];
    [imageQuery whereKey:@"postLocation" nearGeoPoint:self.userLocation withinMiles:7];
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            NSLog(@"error");
        }
        else {
            
            
            for (PFObject *object in objects) {
                PFFile *file = [object objectForKey:@"imageFile"];
                
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        
                        
                        [imageQuery cancel];
                        
                        
                    }
                    
                } progressBlock:^(int percentDone) {
                    
                    
                }];
            }
        }
    }];
    
    return nil;
    
}



@end
