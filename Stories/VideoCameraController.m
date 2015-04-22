//
//  VideoCameraController.m
//  StoriesAWS
//
//  Created by Evan Latner on 3/29/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "VideoCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "SCAudioTools.h"
#import "SCRecorderFocusView.h"
#import "SCRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCRecordSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WelcomeViewController.h"



#define kVideoPreset AVCaptureSessionPresetLow


@interface VideoCameraController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
}

@property (strong, nonatomic) SCRecorderFocusView *focusView;


@end

@implementation VideoCameraController

#pragma mark - UIViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

//- (UIStatusBarStyle) preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

#endif

#pragma mark - Left cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    PFUser *currentuser = [PFUser currentUser];
    if (currentuser) {
        
        // NSLog(@"got user");
        [[PFUser currentUser] incrementKey:@"RunCount"];
        [[PFUser currentUser] saveInBackground];
        
        
        if ([[[PFUser currentUser] objectForKey:@"LocationStatus"] isEqualToString:@"Disabled"]) {
            
            //[self performSegueWithIdentifier:@"welcome" sender:self];
            
            WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
            
            [self.navigationController pushViewController:wvc animated:NO];
            
        }
        
        else {
            
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                
                
                NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
                
                self.userLocation = geoPoint;
                
            }];

            
            
        }
        
    }
    
    else {
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }

    
    if (![PFUser currentUser]) {
        
        
    }
    
    else {
        

    self.capturePhotoButton.alpha = 0.0;
    
    _recorder.recordSession = nil;
    
    
    _ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _ghostImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ghostImageView.alpha = 0.2;
    _ghostImageView.userInteractionEnabled = NO;
    _ghostImageView.hidden = YES;
    
    [self.view insertSubview:_ghostImageView aboveSubview:self.previewView];
    
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = [SCRecorderTools bestSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(7, 1); //
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-60, CGRectGetWidth(self.view.frame), 60)];
    [overlayView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:overlayView];
    
    
    
    self.selfieButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-54, 4.5, 32, 32)];
    [self.selfieButton setImage:[UIImage imageNamed:@"flipCam"] forState:UIControlStateNormal];
    [self.selfieButton addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[frontcamera setBackgroundColor:[UIColor clearColor]];
    [overlayView addSubview:self.selfieButton];
    
    self.flash = [[UIButton alloc]initWithFrame:CGRectMake(15, 18, 35, 35)];
    [self.flash setImage:[UIImage imageNamed:@"flashYo"] forState:UIControlStateNormal];
    [self.flash setImage:[UIImage imageNamed:@"flashYo"] forState:UIControlStateSelected];
    [self.flash addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flash];
    
    
    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    
    _recorder.initializeRecordSessionLazily = YES;
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSError *error = nil;
        NSLog(@"%@", error);
        
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
    
    
    self.cameraButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-42, CGRectGetHeight(self.view.bounds)-95, 85, 85)];
    [self.cameraButton setImage:[UIImage imageNamed:@"snapVideo"] forState:UIControlStateNormal];
    [self.cameraButton setImage:[UIImage imageNamed:@"snapVideoSelected"] forState:UIControlStateHighlighted];
    [self.cameraButton addTarget:self action:@selector(recordVid) forControlEvents:UIControlEventTouchDown];
    [self.cameraButton addTarget:self action:@selector(stopVid) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.cameraButton setTintColor:[UIColor blueColor]];
    [self.cameraButton.layer setCornerRadius:20.0];
    [self.view addSubview:self.cameraButton];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(methodToShowViewOnTop)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.menu = [[UIButton alloc]initWithFrame:CGRectMake(22, CGRectGetHeight(self.view.frame)-54, 31, 31)];
    [self.menu setImage:[UIImage imageNamed:@"menuYo.png"] forState:UIControlStateNormal];
    [self.menu addTarget:self action:@selector(ScrollToHomeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menu];

    
   [self.videoProgress setTransform:CGAffineTransformMakeScale(1.0, 20.0)];
    
    [self.videoProgress setProgress:0.f];
    
    
    }
}

-(void)menuButtonBounce {
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
    [self.menu.layer addAnimation:anim forKey:nil];
    
}

-(void)selfieButtonBounce {
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
    [self.selfieButton.layer addAnimation:anim forKey:nil];
    
}

-(void)ScrollToHomeView {
    
    [self menuButtonBounce];
    
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:0 animated:NO];
    
    
}

-(void)methodToShowViewOnTop{
    
    // NSLog(@"ACTIVEEEE");
    
    UIImageView *imageView = (UIImageView *)[UIApplication.sharedApplication.keyWindow.subviews.lastObject viewWithTag:101];   // search by the same tag value
    [imageView removeFromSuperview];
    
    
    [self reloadInputViews];
    
    
}


- (void)recordVid {
    
    NSLog(@"record");
    
    if ([[[PFUser currentUser] objectForKey:@"userStatus"] isEqualToString:@"anon"]) {
        
        NSLog(@"Not a registered User");
        
        SignupViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Signup"];
        svc.userLocation = self.userLocation;
        svc.recordSession = _recordSession;
        [self.navigationController pushViewController:svc animated:YES];
        
        
    }
    
    else {

    
    self.menu.hidden = YES;
    self.flash.hidden = YES;
    self.selfieButton.hidden = YES;
    
    [self.cameraButton setHighlighted:YES];
    
    
    [_recorder record];
        
    }
    
}

-(void)stopVid {
    
    NSLog(@"stop recording");
    
    self.videoProgress.hidden = YES;
    
    CMTime currentTime = kCMTimeZero;
    
    currentTime = _recorder.recordSession.currentRecordDuration;
    
    
    if (_recorder.recordSession.currentRecordDuration.timescale <= 2) {
        
        NSLog(@"Bindo %f", CMTimeGetSeconds(currentTime));
        
        [_recorder pause];
        
        self.menu.hidden = NO;
        self.flash.hidden = NO;
        self.selfieButton.hidden = NO;
        self.videoProgress.hidden = NO;
    }
    
    
    else {
    
    [_recorder pause:^{
        [self saveAndShowSession:_recorder.recordSession];
    }];
        
    }
    
    
}





- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBuffer:(SCRecordSession *)recordSession {
    //    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.menu.hidden = NO;
    self.flash.hidden = NO;
    self.selfieButton.hidden = NO;
    self.videoProgress.hidden = NO;
    
    [self.videoProgress setProgress:0.f];
    
    
    [self prepareCamera];
    
    self.navigationController.navigationBarHidden = YES;
    [self updateTimeRecordedLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunningSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder endRunningSession];
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {
    [self.focusView hideFocusAnimation];
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)showVideo {
    
    NSLog(@"VIDEO: %@", _recordSession);
    
    VideoPreviewViewController *vpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPreview"];
    
    vpvc.recordSession = _recordSession;
    vpvc.userLocation = self.userLocation;
    
    [self.navigationController pushViewController:vpvc animated:NO];
    
}


- (void)showPhoto:(UIImage *)photo {
    _photo = photo;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}

- (void) handleReverseCameraTapped:(id)sender {
    [self selfieButtonBounce];

    [_recorder switchCaptureDevices];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    NSLog(@"OKOKOKOK");
    
    NSURL *url = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    [_recorder.recordSession addSegment:url];
    _recordSession = [SCRecordSession recordSession];
    [_recordSession addSegment:url];
    
    NSLog(@"DA URL IS: %@", url);
    
    
    [self showVideo];
}
- (void) handleStopButtonTapped:(id)sender {
    [_recorder pause:^{
        [self saveAndShowSession:_recorder.recordSession];
    }];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
    [self showVideo];
}

- (void) handleRetakeButtonTapped:(id)sender {
    SCRecordSession *recordSession = _recorder.recordSession;
    
    if (recordSession != nil) {
        _recorder.recordSession = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endRecordSegment:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
    [self prepareCamera];
    [self updateTimeRecordedLabel];
}

- (IBAction)switchCameraMode:(id)sender {
    
    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        [UIView animateWithDuration:0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.capturePhotoButton.alpha = 0.0;
            self.recordView.alpha = 1.0;
            self.retakeButton.alpha = 1.0;
            self.stopButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _recorder.sessionPreset = kVideoPreset;
            [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeOff;
        }];
    } else {
        [UIView animateWithDuration:0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordView.alpha = 0.0;
            self.retakeButton.alpha = 0.0;
            self.stopButton.alpha = 0.0;
            self.capturePhotoButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            //_recorder.sessionPreset = AVCaptureSessionPresetPhoto;
            [self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeAuto;
        }];
    }
}

- (IBAction)switchFlash:(id)sender {
    NSString *flashModeString = nil;
    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeOn;
                break;
            case SCFlashModeOn:
                flashModeString = @"Flash : Light";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Auto";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
    } else {
        switch (_recorder.flashMode) {
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            default:
                break;
        }
    }
    
    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
}

- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.recordSession = session;
    }
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession {
    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginRecordSegment:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didEndRecordSegment:(SCRecordSession *)recordSession segmentIndex:(NSInteger)segmentIndex error:(NSError *)error {
    NSLog(@"End record segment %d at %@: %@", (int)segmentIndex, segmentIndex >= 0 ? [recordSession.recordSegments objectAtIndex:segmentIndex] : nil, error);
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.recordSession != nil) {
        currentTime = _recorder.recordSession.currentRecordDuration;
    }
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"Recorded - %.2f sec", CMTimeGetSeconds(currentTime)];
    
    float dur = CMTimeGetSeconds(currentTime);
    float durMili = dur*205;
    
    
    [self.videoProgress setProgress:durMili animated:YES];
    
    
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
    
}


- (IBAction)capturePhoto:(id)sender {
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            [self showPhoto:image];
        } else {
            [self showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription];
        }
    }];
}

- (void)updateGhostImage {
    _ghostImageView.image = [_recorder snapshotOfLastAppendedVideoBuffer];
    _ghostImageView.hidden = !_ghostModeButton.selected;
}

- (IBAction)switchGhostMode:(id)sender {
    _ghostModeButton.selected = !_ghostModeButton.selected;
    _ghostImageView.hidden = !_ghostModeButton.selected;
}

@end
