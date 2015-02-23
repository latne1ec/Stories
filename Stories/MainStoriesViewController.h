//
//  MainStoriesViewController.h
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KASlideShow.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ProgressHUD.h"
#import "HomeTableViewController.h"

@interface MainStoriesViewController : UIViewController <KASlideShowDelegate> {
    int secondsLeft;
    int countDown;
}

- (IBAction)popHome:(id)sender;

@property (nonatomic, strong) NSArray *photos;

//@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) PFGeoPoint *userLocation;



@property (strong, nonatomic) IBOutlet UIView *captionBkg;


@property (strong, nonatomic) IBOutlet UILabel *photoCaption;


@property (strong, nonatomic) IBOutlet PFImageView *parseImage;

@property (strong, nonatomic) IBOutlet UILabel *countDownLabel;

@property (nonatomic, strong) UIImage *test;

@property (nonatomic, strong) NSArray *daPics;


@property (strong, nonatomic) IBOutlet UILabel *noStoriesLabel;

@property (nonatomic, strong) PFQuery *testQuery;

@property (nonatomic, strong) NSTimer *imageTimer;


@property (strong, nonatomic) IBOutlet UIImageView *timerBkg;






@end
