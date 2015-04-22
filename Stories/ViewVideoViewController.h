//
//  ViewVideoViewController.h
//  StoriesAWS
//
//  Created by Evan Latner on 4/1/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SDWebImageManager.h"
#import "SCVideoPlayerView.h"
#import "SCRecorder.h"

@class ViewVideoViewController;

@protocol ViewVideoViewControllerDelegate <NSObject>

-(void)disableScroll;
-(void)enableScroll;


@end


@interface ViewVideoViewController : UIViewController <UITextFieldDelegate>


@property(nonatomic,weak) IBOutlet id<ViewVideoViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *batchOne;
@property (nonatomic, strong) NSArray *batchTwo;
@property (nonatomic, strong) NSArray *batchThree;
@property (nonatomic, strong) NSArray *batchFour;
@property (nonatomic, strong) NSArray *batchFive;
@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayerItem *avPlayerItem;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) UITapGestureRecognizer *tapTap;
@property (nonatomic, strong) NSString *contentUrl;
@property (strong, nonatomic) IBOutlet UIView *videoView;

@property (nonatomic, strong) NSTimer *testTimer;
@property (nonatomic, strong) NSMutableArray *urls;

@property (nonatomic, strong) AVQueuePlayer *qPlayer;
@property (nonatomic, strong) AVQueuePlayer *qPlayerTwo;
@property (nonatomic, strong) id playerObserver;
@property (nonatomic, strong) PFGeoPoint *featuredLocation;


@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (nonatomic, strong) NSMutableArray *dontShowTwice;
@property (nonatomic, strong) NSMutableArray *test;


@property (strong, nonatomic) IBOutlet UIImageView *yellowBkg;
@property (strong, nonatomic) IBOutlet UILabel *noPostsLabel;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipe;



- (IBAction)goHome:(id)sender;

- (IBAction)pauseVideo:(id)sender;

@end
