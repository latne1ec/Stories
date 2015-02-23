//
//  HomeTableViewController.h
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SCSwipeableFilterView.h"
#import "CameraViewController.h"
#import "MainStoriesViewController.h"
#import "FirstFeaturedViewController.h"
#import "SecondFeaturedViewController.h"



@interface HomeTableViewController : UITableViewController

//@property (nonatomic,strong) CameraViewController *imagePicker;
@property(nonatomic,strong) AVCaptureSession *captureSession;



@property (strong, nonatomic) IBOutlet UITableViewCell *myCollegeCell;

@property (strong, nonatomic) IBOutlet UIImageView *myCollegeStory;

@property (nonatomic, strong) PFGeoPoint *userLocation;
@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) UIImage *image;

@property (strong, nonatomic) IBOutlet UITableViewCell *topRatedCell;
@property (strong, nonatomic) IBOutlet UIImageView *allCollegesPic;

@property (nonatomic, strong) NSString *thePhotoCaption;

- (IBAction)showCamera:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *featuredStoryName;

@property (strong, nonatomic) IBOutlet UITableViewCell *secondFeaturedStoryCell;

@property (strong, nonatomic) IBOutlet UIImageView *secondFeaturedPic;
@property (strong, nonatomic) IBOutlet UILabel *secondFeaturedStoryName;


@property (nonatomic, strong) PFQuery *imageQuery;






@end
