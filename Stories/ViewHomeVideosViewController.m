//
//  ViewHomeVideosViewController.m
//  Spotshot
//
//  Created by Evan Latner on 4/6/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "ViewHomeVideosViewController.h"
#import "ProgressHUD.h"
#import "YZSwipeBetweenViewController.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"


@interface ViewHomeVideosViewController ()

@property (nonatomic, strong) YZSwipeBetweenViewController *yzBaby;


@end

@implementation ViewHomeVideosViewController

bool canSkip;

int nextIndex;
float daTime;


-(BOOL)prefersStatusBarHidden {
    
    return YES;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([PFUser currentUser]) {
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            
            if (!error) {
                
                NSLog(@"Got user location");
                [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
                [[PFUser currentUser] saveInBackground];
                
                self.userLocation = geoPoint;
                [self queryForFirstBatch];
            }
        }];
    }

    
    
    
    _noPostsLabel.hidden = YES;
    
    canSkip = YES;
    
    self.qPlayer = [[AVQueuePlayer alloc] init];
    self.avPlayerItem = [[AVPlayerItem alloc] init];
    
    self.dontShowTwice = [NSMutableArray array];
    self.urlAsset = [[AVURLAsset alloc] init];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    //[self queryForFirstBatch];
    //[self queryForStories];
    
    self.yzBaby = [[YZSwipeBetweenViewController alloc] init];
    self.delegate = self.yzBaby;
    
    self.tapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    self.tapTap.delegate = (id)self;
    self.tapTap.numberOfTapsRequired = 1;
    self.tapTap.numberOfTouchesRequired = 1;
    self.tapTap.delaysTouchesBegan = YES;      //Important to add
    [self.view addGestureRecognizer:self.tapTap];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    
    
    [ProgressHUD show:nil];
    [self.delegate performSelector:@selector(disableScroll)];
    
    
    self.homeButton = [[UIButton alloc]initWithFrame:CGRectMake(12, CGRectGetHeight(self.view.frame)-44, 30, 30)];
    [self.homeButton setImage:[UIImage imageNamed:@"menuYo"] forState:UIControlStateNormal];
    [self.homeButton addTarget:self action:@selector(goHome:) forControlEvents:UIControlEventTouchDown];
    [self.homeButton addTarget:self action:@selector(goHome:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.homeButton];
    
    [self.videoProgress setProgress:1];
    
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    self.swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flagContent)];
    self.swipe.delegate = (id)self;
    self.swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.videoView addGestureRecognizer:self.swipe];
    
    [self performSelector:@selector(playy) withObject:nil afterDelay:3];
    
    //Added this
    [self queryForFirstBatch];

}

-(void)playy {
    
    [self.qPlayer play];
    
    self.testTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(checkIfPlayerIsPlaying) userInfo:nil repeats:YES];
    //[timer fire];
    [[NSRunLoop currentRunLoop] addTimer:self.testTimer forMode:NSRunLoopCommonModes];
    
}

-(void)flagContent {
    
    NSLog(@"flag");
    
    [self.videoView makeToast:@"Post flagged" duration:1.25 position:CSToastPositionBottom title:nil];
    
    [PFAnalytics trackEvent:@"flaggedContent"];
    
    
}


-(void)menuButtonBounce {
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
    [self.homeButton.layer addAnimation:anim forKey:nil];
    
}


-(void)viewWillDisappear:(BOOL)animated {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryForFirstBatch) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBatchOne) object:nil];
    
    [self.avPlayer pause];
    [ProgressHUD dismiss];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.testTimer invalidate];
    [self.delegate performSelector:@selector(enableScroll)];
    
}

-(void)checkIfPlayerIsPlaying {
    
    if (self.qPlayer.rate > 0.0 && !self.qPlayer.error) {
        [ProgressHUD dismiss];
        
        _noPostsLabel.hidden = NO;
        _noPostsLabel.text = @"loading..";
        
        if (self.batchOne.count > 1) {
            
        _yellowBkg.hidden = YES;
            [ProgressHUD dismiss];
            
        }
        
        else {
            
            [self dismissProgressView];
        }
        
    }
    else {
        [ProgressHUD show:nil];
        [self.qPlayer play];
    }
}



-(void)handleSingleTap {
    
    nextIndex = nextIndex + 1;
    
    
    if (self.qPlayer.status == AVPlayerStatusReadyToPlay) {
        
            //Added This
            //[self.avPlayer pause];
            
            [self.qPlayer advanceToNextItem];
            [self.qPlayer play];
        
        }
    
    
    if (self.qPlayer.items.count <1) {
        
        _noPostsLabel.hidden = YES;
        [self.navigationController popViewControllerAnimated:NO];
        
    }
    
    [self.qPlayer play];
    
}

-(void)showBatchOne {
    
    NSLog(@"Batch 1");
    NSArray* reversedArray = [[self.batchOne reverseObjectEnumerator] allObjects];
    
    for (id object in [reversedArray valueForKeyPath:@"awsUrl"]) {
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:object] options:nil];
        
                self.avPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
                [self.qPlayer insertItem:self.avPlayerItem afterItem:nil];
                NSLog(@"Ther");
        
    }
    
    self.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.qPlayer];
    [self.avPlayerLayer setFrame:self.videoView.frame];
    [self.videoView.layer addSublayer:self.avPlayerLayer];
    [self.qPlayer seekToTime:kCMTimeZero];
    [self.qPlayer play];
    NSLog(@"FUCKING PLAY");
    
}

-(void)queryForFirstBatch {
    
    PFGeoPoint *southwest = [PFGeoPoint geoPointWithLatitude:self.userLocation.latitude * 0.999 longitude:self.userLocation.longitude * 1.001 ];
    
    PFGeoPoint *northeast = [PFGeoPoint geoPointWithLatitude:self.userLocation.latitude * 1.001 longitude:self.userLocation.longitude * +0.999];
    
    NSLog(@"Yaaaaa");
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postLocation" withinGeoBoxFromSouthwest:southwest toNortheast:northeast];
    [query setSkip:0]; //65, 70, 45
    [query setLimit:50]; //10, 5
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count == 0) {
            
            [self performSelector:@selector(dismissProgressView) withObject:nil afterDelay:2];
        }
        else {
            
        
        self.batchOne = objects;
        [self performSelector:@selector(showBatchOne) withObject:nil];
            
        }
        
    }];
}


- (IBAction)goHome:(id)sender {
    
    [self menuButtonBounce];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryForFirstBatch) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBatchOne) object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
    [self.qPlayer pause];
    self.avPlayer = nil;
    self.qPlayer = nil;
    [self.testTimer invalidate];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.delegate = self.yzBaby;
    [self.delegate performSelector:@selector(enableScroll)];
}

- (IBAction)pauseVideo:(id)sender {
    
    [self.qPlayer pause];
    [self.testTimer invalidate];
}

-(void)appClosed{
    
    [self.qPlayer pause];
    [self.navigationController popViewControllerAnimated:NO];
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


-(void)dismissProgressView {
    
    [ProgressHUD dismiss];
    _yellowBkg.hidden = NO;
    _noPostsLabel.hidden = NO;
    [self.qPlayer play];
    
}




@end
