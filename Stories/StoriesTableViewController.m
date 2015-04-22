//
//  StoriesTableViewController.m
//  Stories
//
//  Created by Evan Latner on 2/27/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "StoriesTableViewController.h"
#import "SDWebImageManager.h"
#import "SCLAlertView.h"
#import "UIView+Shake.h"
#import "UIView+Toast.h"
#import "SSARefreshControl.h"


@interface StoriesTableViewController () <SSARefreshControlDelegate> {
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property(nonatomic,strong) AVCaptureSession *captureSession;


/////
@property (nonatomic, strong) MainStoriesViewController *daMvc;
@property (nonatomic, strong) SSARefreshControl *refreshControl;
@property (nonatomic, strong) ViewVideoViewController *vvvc;




/////

@end

@implementation StoriesTableViewController 

@synthesize stories;
@synthesize score;
@synthesize longTap;
@synthesize refreshControl;
@synthesize daHomeName;
@synthesize searchBar;
@synthesize searchedStory;
@synthesize currentIndex;



-(BOOL)prefersStatusBarHidden {
    
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setScrollsToTop:YES];
    
        if([UIScreen mainScreen].bounds.size.height <= 568.0) {
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"camRed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(showCamera:)];
            
            [score setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:@"AvenirNext-DemiBold" size:20.0], NSFontAttributeName,
                                           [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                           nil]
                                 forState:UIControlStateNormal];

            
        }
    
    else {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"camRed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(showCamera:)];
        
        [score setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont fontWithName:@"AvenirNext-DemiBold" size:20.0], NSFontAttributeName,
                                       [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                       nil]
                             forState:UIControlStateNormal];
        
        }

    

    
    
    if ([PFUser currentUser]) {
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSString *daScore = [formatter stringFromNumber:[[PFUser currentUser] objectForKey:@"userScore"]];
        NSString *textBody = @" score";
        NSString* newString = [textBody stringByReplacingOccurrencesOfString:@"score" withString:daScore];

        self.score.title = newString;

        [score setTarget:self];
        [score setAction:@selector(showScore)];
        
    }
    
    
    else {
        
        self.score.title = @"100";
        [score setTarget:self];
        [score setAction:@selector(showScore)];
    }
    
    
    ///GET LOCATION
    if([PFUser currentUser]) {
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
    
        if (!error) {
            
//            NSLog(@"Got user location");
            
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            
            self.userLocation = geoPoint;
            
            [self queryForHomePic];
            [self queryForStories];
                
            }
        }];
    }
    
    else {
        
       // NSLog(@"NO USER YET");
        
        [self queryForTempHomePic];
        
    }
    
    [self queryForStories];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.tableView.tableFooterView = [UIView new];


    [self performSelector:@selector(reloadTableview) withObject:nil afterDelay:0.50];

    
    // Reverse Geocoding
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    [self getLocation];
    
    self.refreshControl = [[SSARefreshControl alloc] initWithScrollView:self.tableView andRefreshViewLayerType:SSARefreshViewLayerTypeOnScrollView];
    self.refreshControl.delegate = self;
    
    
    //Search Bar
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.searchBar.delegate = self;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [tap setCancelsTouchesInView:NO];

    

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableBkg.png"]];
    [self.tableView setBackgroundView:imageView];
    
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    scrollView.userInteractionEnabled = YES;    
    self.tableView.userInteractionEnabled = YES;
    
}

//*********************************************
// Dismiss Active Keyboard

- (void) dismissKeyboard {
    // add self
    [self.searchBar resignFirstResponder];
}
//*********************************************


- (void)beganRefreshing {
    
    [self queryForStories];
    [self queryForHomePic];
    
}



-(void)reloadTableview {
    //NSLog(@"CALLED");
    [self.tableView reloadData];
    
}

-(void)showScore {

    LeaderboardViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Leaderboard"];
    [self.navigationController pushViewController:lvc animated:NO];
    
}

-(void)refreshYo {
    
    [self queryForHomePic];
    [self queryForStories];
    
}




-(void)viewWillAppear:(BOOL)animated {
    
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

-(void)appClosed{

    NSLog(@"closed");
    
    [self dismissKeyboard];
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
                                                                           [[UIScreen mainScreen] bounds].size.width,
                                                                           [[UIScreen mainScreen] bounds].size.height)];
    
    imageView.tag = 101;
    [imageView setImage:[UIImage imageNamed:@"splashYo"]];
    [UIApplication.sharedApplication.keyWindow addSubview:imageView];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:1 animated:NO];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self dismissKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
    
}




- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1]];
     
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
    
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:0.329 green:0.302 blue:0.302 alpha:1]];
 
    
    
    if (section == 0) {
        
        return @"Home";
    }
    if (section == 1) {
        
        return @"Featured";
        
    }
    return nil;
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    }
    if (section == 1){
        
        return self.stories.count;
    }

    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Home";
    static NSString *CellIdentifier2 = @"Featured";
    

    HomeTableCell *cell = (HomeTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    FeaturedTableCell *cell2 = (FeaturedTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell2 == nil) {
        cell2 = [[FeaturedTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        cell2.featuredStoryImage.image = nil;
    }
    
    
    if (indexPath.section == 0) {
        
    
        cell.homeName.text = daHomeName;
        
        if (indexPath.row == 0) {
            
        if (self.home == nil) {
            NSLog(@"Gottttt ittt boss");
            cell.homeStoryImage.image = [UIImage imageNamed:@"noVids"];
            cell.homeStoryImage.layer.cornerRadius = 2;
            cell.homeStoryImage.clipsToBounds = YES;
        }
            
        else {
        
        PFFile *homeImage = [self.home objectForKey:@"thumbnailPic"];
        PFImageView *ImageView = (PFImageView*)cell.homeStoryImage;
        ImageView.image = [UIImage imageNamed:@"placeholder"];
        ImageView.file = homeImage;
        [ImageView loadInBackground];
        
        cell.homeStoryImage.layer.cornerRadius = 5;
        cell.homeStoryImage.clipsToBounds = YES;
            
        cell.bkgView.layer.cornerRadius = 2;
        cell.bkgView.clipsToBounds = YES;
            
        }
            
        }
        
        
        return cell;
        
        
    }
    
    if (indexPath.section == 1) {
        
        
        
        if (self.stories) {
        
        cell2.featuredStoryImage.image = nil;
            
        if (cell2.featuredStoryImage.tag == 25) {
        
            
        PFObject *object = [self.stories objectAtIndex:indexPath.row];
        
        cell2.featuredStoryName.text = [object objectForKey:@"storyName"];
        PFFile *storyImage = [object objectForKey:@"storyImage"];

        PFImageView *ImageView = (PFImageView*)cell2.featuredStoryImage;
        ImageView.image = [UIImage imageNamed:@"placeholder"];
        ImageView.file = storyImage;
        [ImageView loadInBackground];
        
        cell2.featuredStoryImage.layer.cornerRadius = 5;
        cell2.featuredStoryImage.clipsToBounds = YES;
            
        cell2.bkgView.layer.cornerRadius = 2;
        cell2.bkgView.clipsToBounds = YES;

            
            
        return cell2;
            
            
            }
        }
        
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        ViewHomeVideosViewController *vvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewHomeVideos"];
        [self dismissKeyboard];
        vvc.userLocation = self.userLocation;
        [self.navigationController pushViewController:vvc animated:NO];
        
    }
    
    else {
        
        ViewVideoViewController *vvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewVideo"];

        
        FeaturedTableCell *cell2 = (FeaturedTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        PFObject *object = [self.stories objectAtIndex:indexPath.row];
        cell2.storyLocation = [object objectForKey:@"storyLocation"];
        
        NSLog(@"Location: %@", cell2.storyLocation);
        
        vvc.featuredLocation = cell2.storyLocation;
        
        [self.navigationController pushViewController:vvc animated:NO];
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 72.0f;
    }
    if (indexPath.section == 1)   {
        return 72.0f;
    }
    
    return 0;
}

- (IBAction)showCamera:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:1];
    
}


-(void)endRefresh {
    
    [self.refreshControl endRefreshing];
    
}



///************************************
//Get Home Image Pic

- (PFQuery *)queryForHomePic {
    
    
   // NSLog(@"home pic query called?");
    
    if (!self.userLocation) {
        NSLog(@"nilllll");
        
        [self getUserLocation];
        
        return nil;
    }
    
    PFGeoPoint *southwest = [PFGeoPoint geoPointWithLatitude:self.userLocation.latitude * 0.999 longitude:self.userLocation.longitude * 1.001 ];
    
    PFGeoPoint *northeast = [PFGeoPoint geoPointWithLatitude:self.userLocation.latitude * 1.001 longitude:self.userLocation.longitude * +0.999];
    

    //[ProgressHUD show:nil Interaction:NO];
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query whereKey:@"postLocation" withinGeoBoxFromSouthwest:southwest toNortheast:northeast];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            self.home = object;
            [self.tableView reloadData];

            [self performSelector:@selector(endRefresh) withObject:nil afterDelay:1.15];
            
        }
        
        if (self.home == nil) {
            NSLog(@"WOWOWOWOWOWOWO NiLLLLL");
            
          
            HomeTableCell *cell = (HomeTableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            
            cell.homeStoryImage.image = [UIImage imageNamed:@"noVids"];
            
            NSLog(@"IMAGE == %@", cell.homeStoryImage.image);
        }
        
        if (error) {
            
            [ProgressHUD showError:@"Network Error"];
        }
        
    }];

    return nil;
    
}

///************************************


///************************************
//Get Featured Stories

- (PFQuery *)queryForStories {
    
    //[ProgressHUD show:nil Interaction:NO];
    PFQuery *query = [PFQuery queryWithClassName:@"FeaturedStories"];
    [query orderByAscending:@"storyName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            //[ProgressHUD dismiss];
            self.stories = [objects mutableCopy];
            [self.tableView reloadData];
            [self performSelector:@selector(endRefresh) withObject:nil afterDelay:1.15];
            
            
        }
        
        if (error) {
            
            [ProgressHUD showError:@"Network Error"];
        }
        
    }];
    
    return nil;
    
}

///************************************



-(void)getUserLocation {
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (!error) {
            
           // NSLog(@"Got user location");
            
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            
            self.userLocation = geoPoint;
            
            [self queryForHomePic];
            //[self.tableView reloadData];
        }
        
        if (error) {
            
            [ProgressHUD showError:@"Network Error"];
            
        }
        
    }];
    
}

///////***********************************************


-(void)queryForTempHomePic {
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            //[ProgressHUD dismiss];
            
            //NSLog(@"Got temp home Pic");
            
            self.home = object;
            //[self.tableView reloadData];
            
        }
        
        if (error) {
            
            NSLog(@"home pic error");
            
            [ProgressHUD showError:@"Network Error"];
        }
        
    }];

    
    
    
}

///////***********************************************

- (void)getLocation {
    
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    //[locationManager requestAlwaysAuthorization];
    
    
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    
    CLLocation *currentLocation = newLocation;
    [locationManager stopUpdatingLocation];
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {

        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            daHomeName = [NSString stringWithFormat:@"%@",
                          placemark.locality]; //placemark.administrativeArea];
            
          //  NSLog(@"Success: %@", daHomeName);
            
            
            [self performSelector:@selector(reloadTableview) withObject:nil afterDelay:1];
            
                        
            
        }
    } ];
    
}


//*************************************
// Search Userbase functionality

- (void)searchUsers:(NSString *)search_lower {
    
   
        NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    
        
        PFQuery *query = [PFQuery queryWithClassName:@"FeaturedStories"];
        [query whereKey:@"searchedName" hasPrefix:searchText];
        [query whereKey:@"searchedName" containsString:searchText];
        [query setLimit:100];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error == nil) {
                
                
                
                
//                NSUInteger nextPic = (currentIndex+1)%[objects count];
                
                
                [stories removeAllObjects];
                [stories addObjectsFromArray:objects];
                [self.tableView reloadData];
                self.searchedStory = objects.lastObject;
                
                NSLog(@"STORY: %@", self.searchedStory);
                
                
            }
            else [ProgressHUD showError:@"Network error"];
        }];
    
}
//*********************************************





//*********************************************
// Search Bar Properties

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if ([searchText length] > 0) {
        [self searchUsers:[searchText lowercaseString]];
    }
    
    else {
        
        [self queryForStories];
        
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_ {
    [searchBar_ setShowsCancelButton:NO animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_ {
    [searchBar_ setShowsCancelButton:NO animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self searchBarCancelled];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
    
    NSLog(@"SEARCHH");
    
    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self searchUsers:searchText];
    //[searchBar_ resignFirstResponder];
}
- (void)searchBarCancelled {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}
//*********************************************





@end
