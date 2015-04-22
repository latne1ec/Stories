//
//  ViewVideoViewController.m
//  StoriesAWS
//
//  Created by Evan Latner on 4/1/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "ViewVideoViewController.h"
#import "ProgressHUD.h"
#import "YZSwipeBetweenViewController.h"
#import "UIView+Toast.h"

@interface ViewVideoViewController ()


@property (nonatomic, strong) YZSwipeBetweenViewController *yzBaby;
@property (nonatomic, strong) NSNumberFormatter *formatter;


@end

@implementation ViewVideoViewController

bool canSkip;

int nextIndex;

-(BOOL)prefersStatusBarHidden {
    
    return YES;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.formatter = [NSNumberFormatter new];
    [self.formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    
    _noPostsLabel.hidden = YES;
    

    canSkip = YES;
    
    self.qPlayer = [[AVQueuePlayer alloc] init];
    self.avPlayerItem = [[AVPlayerItem alloc] init];
    
    self.dontShowTwice = [NSMutableArray array];
    self.urlAsset = [[AVURLAsset alloc] init];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [self queryForFirstBatch];
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
    
    self.testTimer = [NSTimer timerWithTimeInterval:2.5 target:self selector:@selector(checkIfPlayerIsPlaying) userInfo:nil repeats:YES];
    //[timer fire];
    [[NSRunLoop currentRunLoop] addTimer:self.testTimer forMode:NSRunLoopCommonModes];
    
    [ProgressHUD show:nil];
    [self.delegate performSelector:@selector(disableScroll)];
    
    
    UIButton *home = [[UIButton alloc]initWithFrame:CGRectMake(12, CGRectGetHeight(self.view.frame)-44, 30, 30)];
    [home setImage:[UIImage imageNamed:@"menuYo"] forState:UIControlStateNormal];
    [home addTarget:self action:@selector(goHome:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:home];
    
    self.swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flagContent)];
    self.swipe.delegate = (id)self;
    self.swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.videoView addGestureRecognizer:self.swipe];
    
    
    
    
    
}

-(void)flagContent {
    
    NSLog(@"flag");
    
    [self.videoView makeToast:@"Post flagged" duration:1.25 position:CSToastPositionBottom title:nil];
    
    [PFAnalytics trackEvent:@"flaggedContent"];
    
    
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
    
    if (self.qPlayer.rate > 0 && !self.qPlayer.error) {
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

-(void) timer {
    
    
}

-(void)handleSingleTap {
    
    nextIndex = nextIndex + 1;
    
    
        if (self.qPlayer.status == AVPlayerStatusReadyToPlay) {
  
            if (canSkip == YES) {
                NSLog(@"ADVANCE");
                
                [self.qPlayer advanceToNextItem];
                [self.qPlayer play];
            }
            
            else {
                
                NSLog(@"STALLL");
                [ProgressHUD show:nil];
            }
    }
    
    
    
    if (self.qPlayer.items.count <1) {
        
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
    
    PFGeoPoint *southwest = [PFGeoPoint geoPointWithLatitude:self.featuredLocation.latitude * 0.999 longitude:self.featuredLocation.longitude * 1.001 ];
    
    PFGeoPoint *northeast = [PFGeoPoint geoPointWithLatitude:self.featuredLocation.latitude * 1.001 longitude:self.featuredLocation.longitude * +0.999];
    
    NSLog(@"Location: %@", self.featuredLocation);
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postLocation" withinGeoBoxFromSouthwest:southwest toNortheast:northeast];
    [query setSkip:0]; //65, 70
    [query setLimit:75]; //10, 5
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count == 0) {
            
            [self performSelector:@selector(dismissProgressView) withObject:nil afterDelay:2];
            
        }
        else {
            

        self.batchOne = objects;
        //[self showBatchOne];
        
        [self performSelector:@selector(showBatchOne) withObject:nil];
        }
        
    }];
}


- (IBAction)goHome:(id)sender {
    
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

-(void)dismissProgressView {
    
    [ProgressHUD dismiss];
    _yellowBkg.hidden = NO;

    PFUser *user = [PFUser currentUser];
    
    //NSNumber *score = [self.formatter numberFromString:[user objectForKey:@"userScore"]];

    int score = [[user objectForKey:@"userScore"] intValue];
    
    NSLog(@"Score: %d", score);
    
    
    if (score <= 115) {
        
        _noPostsLabel.text = @"locked, boost your score to view.";
    }
    
    else {
        _noPostsLabel.text = @"No videos yet.";
    }
    
    _noPostsLabel.hidden = NO;
    
    [self.qPlayer play];
    
}

- (IBAction)pauseVideo:(id)sender {
    
    [self.qPlayer pause];
    [self.testTimer invalidate];
}
@end
