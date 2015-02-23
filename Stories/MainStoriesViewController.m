//
//  MainStoriesViewController.m
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "MainStoriesViewController.h"


@interface MainStoriesViewController ()

@property (strong,nonatomic) IBOutlet KASlideShow * slideshow;
@property (nonatomic, weak) NSTimer *labelTimer;


@end

@implementation MainStoriesViewController

@synthesize photoCaption;
@synthesize test;
@synthesize daPics;
@synthesize noStoriesLabel;
@synthesize testQuery;
@synthesize imageTimer;






-(BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    noStoriesLabel.hidden = YES;
    
    
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationItem.hidesBackButton = YES;
    
    
    _slideshow.delegate = self;
    [_slideshow setDelay:5]; // Delay between transitions
    [_slideshow setTransitionDuration:0.0]; // Transition duration
    [_slideshow setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
    [_slideshow setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
    
    //Adding Single Tap Gesture
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    doubleTapGestureRecognizer.delegate = (id)self;
    doubleTapGestureRecognizer.numberOfTapsRequired = 1;
    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    doubleTapGestureRecognizer.delaysTouchesBegan = YES;      //Important to add
    [self.slideshow addGestureRecognizer:doubleTapGestureRecognizer];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipe.delegate = (id)self;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.slideshow addGestureRecognizer:swipe];
    
    
    //[self.slideshow addSubview:_captionBkg];
    // [self timerTho];
    //[self startTimer];
    //[_slideshow addSubview:_countDownLabel];
    [_slideshow addSubview:_timerBkg];
    
    [_timerBkg addSubview:_countDownLabel];
    
    [self queryForTable];
    
    //self.view.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.929 alpha:1];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
}




////////////////////////////////////////

- (void) startCountDown {
    
    
    countDown = 5.0;
    _countDownLabel.text = [NSString stringWithFormat:@"%d", countDown];
    _countDownLabel.hidden = FALSE;
    if (!_labelTimer) {
        _labelTimer = [NSTimer scheduledTimerWithTimeInterval:1.00
                                                               target:self
                                                             selector:@selector(updateTime:)
                                                             userInfo:nil
                                                              repeats:YES];
    }
}

- (void)updateTime:(NSTimer *)timerParam {
    countDown--;
    if(countDown == 0) {
        [self clearCountDownTimer];
        
        [self startCountDown];
        //do whatever you want after the countdown
    }
    _countDownLabel.text = [NSString stringWithFormat:@"%d", countDown];
}
-(void) clearCountDownTimer {
    [_labelTimer invalidate];
    _labelTimer = nil;
    _countDownLabel.hidden = TRUE;
}





/////////////////////////////////////////


- (PFQuery *)queryForTable {
    
    if (!self.userLocation) {
        NSLog(@"nilllll");
        
        return nil;
    }
    
    [ProgressHUD show:nil Interaction:NO];
    NSLog(@"Refreshing");
    //PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    self.images = [[NSMutableArray alloc] init];
    
    self.testQuery = [PFQuery queryWithClassName:@"UserPhoto"];
    [testQuery setLimit: 100];
    [testQuery orderByAscending:@"createdAt"];
    [testQuery whereKey:@"postLocation" nearGeoPoint:self.userLocation withinMiles:7];
    [testQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            NSLog(@"error");
        }
        
        if (objects.count == 0) {
            
            [_labelTimer invalidate];
            
            [ProgressHUD dismiss];

            noStoriesLabel.hidden = NO;
            _slideshow.backgroundColor = [UIColor colorWithRed:0.933 green:0.929 blue:0.929 alpha:1];
            
        }
        
        else {
            
            
            for (PFObject *object in objects) {
                PFFile *file = [object objectForKey:@"imageFile"];
                
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        
                        UIImage *image = [UIImage imageWithData:data];
                        
                        NSLog(@"Got image %@", image);
    
                        
                        [self performSelector:@selector(buySomeTime:) withObject:image afterDelay:2.0];
                        
                    }
                    

                    
                } progressBlock:^(int percentDone) {
                    
                    
                }];
            }
        }
    }];
    
    //[self performSelector:@selector(buySomeTime:) withObject:nil afterDelay:7];
    
    [self startShow];

    return nil;

}
            
            
-(void)buySomeTime: (UIImage *)image {
    
    NSLog(@"bying time");
    [ProgressHUD dismiss];
    [_slideshow addImage:image];
    
    //[self startCountDown];

    
}

-(void)startShow {
    
     self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(customslides) userInfo:nil repeats:YES];
    
    [self.imageTimer fire];
    
    
}


-(void)customslides {
    
    NSLog(@"IS THIS CALLED TWICE REALLY FAST?");
    [_slideshow next];
    
    [self clearCountDownTimer];
    
    [self startCountDown];
    
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    NSLog(@"skip");
    [_slideshow next];
    
    [self.imageTimer invalidate];
    
    [self startShow];
    

    [_labelTimer invalidate];
    
    [self startCountDown];

}









//**************

- (void) handleSwipe:(id)sender {
    
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        
        [self popHome:self];
        
    }
}



- (void)viewWillDisappear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [_slideshow stop];
    
    [self.imageTimer invalidate];
    
    
    
}



#pragma mark - Button methods

- (IBAction)previous:(id)sender
{
    [_slideshow previous];
}

- (IBAction)next:(id)sender
{
    [_slideshow next];
}

- (IBAction)startStrop:(id)sender
{
    UIButton * button = (UIButton *) sender;
    
    if([button.titleLabel.text isEqualToString:@"Start"]){
        [_slideshow start];
        [button setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        [_slideshow stop];
        [button setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (IBAction)switchType:(id)sender
{
    UIButton * button = (UIButton *) sender;
    
    if([button.titleLabel.text isEqualToString:@"Fade"]){
        [_slideshow setTransitionType:KASlideShowTransitionFade];
        [button setTitle:@"Slide" forState:UIControlStateNormal];
    }else{
        [_slideshow setTransitionType:KASlideShowTransitionSlide];
        [button setTitle:@"Fade" forState:UIControlStateNormal];
    }
}



- (IBAction)popHome:(id)sender {
    
    
    HomeTableViewController *hvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    
    [self.navigationController pushViewController:hvc animated:NO];
    
    
    
}



@end
