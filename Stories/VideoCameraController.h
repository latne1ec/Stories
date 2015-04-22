//
//  VideoCameraController.h
//  StoriesAWS
//
//  Created by Evan Latner on 3/29/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import "VideoPreviewViewController.h"


@interface VideoCameraController : UIViewController <SCRecorderDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIView *downBar;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
@property (weak, nonatomic) IBOutlet UIButton *capturePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;
@property (nonatomic, strong) IBOutlet UIButton *selfieButton;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIProgressView *videoProgress;
@property (nonatomic, strong) IBOutlet UIButton *flash;
@property (nonatomic, strong) IBOutlet UIButton *menu;
@property (nonatomic, strong) PFGeoPoint *userLocation;




- (IBAction)switchCameraMode:(id)sender;
- (IBAction)switchFlash:(id)sender;
- (IBAction)capturePhoto:(id)sender;
- (IBAction)switchGhostMode:(id)sender;



@end