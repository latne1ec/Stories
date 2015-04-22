//
//  VideoPreviewViewController.h
//  StoriesAWS
//
//  Created by Evan Latner on 3/29/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoPlayerView.h"
#import "SCRecorder.h"
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
#import <Parse/Parse.h>
#import "LPPopupListView.h"
#import <AVFoundation/AVFoundation.h>
#import "SignupViewController.h"

@class VideoPreviewViewController;

@protocol VideoPreviewViewControllerDelegate <NSObject>

-(void)disableScroll;
-(void)enableScroll;


@end



@interface VideoPreviewViewController : UIViewController <SCPlayerDelegate, LPPopupListViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic,weak) IBOutlet id<VideoPreviewViewControllerDelegate> delegate;




@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
@property (nonatomic, strong) IBOutlet UIButton *addStoryButton;
@property (nonatomic, strong) UITextField *caption;
@property (nonatomic, strong) PFGeoPoint *userLocation;
@property(nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) UIImage *thumbnail;

@property (strong, nonatomic) IBOutlet UIButton *postButton;


//AWS
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic, strong) NSString *awsPicUrl;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSURL *daVid;




@end
