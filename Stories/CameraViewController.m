//
//  CameraViewController.m
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@property(nonatomic,strong) AVCaptureSession *captureSession;
@property(nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic,strong) AVCaptureDevice *captureDevice;
@property(nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property(nonatomic,assign) BOOL isCapturingImage;
@property(nonatomic,strong) UIImageView *capturedImageView;
@property(nonatomic,strong) UIImagePickerController *picker;
@property(nonatomic,strong) UIView *imageSelectedView;
@property(nonatomic,strong) UIImage *selectedImage;
@property (nonatomic, strong) NSArray *captionLocation;
@property (nonatomic, strong) NSString *capLoc;


@property (nonatomic, strong) CIContext *context;


@end


@implementation CameraViewController

@synthesize caption;
@synthesize labelCaption;
@synthesize filterSwitcherView;
@synthesize captionLocation;
@synthesize userLocation;
@synthesize imageQuery;




-(BOOL)prefersStatusBarHidden {
    
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
     NSLog(@"VIEW DID LOAD");
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.toolbarHidden = YES;
    
    
    PFUser *currentuser = [PFUser currentUser];
    if (currentuser) {
        
        NSLog(@"got user");
        [[PFUser currentUser] incrementKey:@"RunCount"];
        
        if ([[[PFUser currentUser] objectForKey:@"LocationStatus"] isEqualToString:@"Disabled"]) {
            
            [self performSegueWithIdentifier:@"welcome" sender:self];
        }
        
        else {
        
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
    
        
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            self.userLocation = geoPoint;
            
            if (!error) {
                
                //[self queryForTable];
                
            }
            
        }];
        
        }
    

    
    }
    
    else {
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }

    
    
    // Do any additional setup after loading the view.
    self.captureSession = [[AVCaptureSession alloc]init];
    //self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.capturedImageView = [[UIImageView alloc]init];
    self.capturedImageView.frame = self.view.frame; // just to even it out
    self.capturedImageView.backgroundColor = [UIColor clearColor];
    self.capturedImageView.userInteractionEnabled = YES;
    self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 0) {
        self.captureDevice = devices[0];
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
        
        [self.captureSession addInput:input];
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.captureSession addOutput:self.stillImageOutput];
        
        
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        
        UIButton *camerabutton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-100, 100, 100)];
        [camerabutton setImage:[UIImage imageNamed:@"snapPhoto"] forState:UIControlStateNormal];
        [camerabutton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [camerabutton setTintColor:[UIColor blueColor]];
        [camerabutton.layer setCornerRadius:20.0];
        [self.view addSubview:camerabutton];
        
        UIButton *flashbutton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 30, 31)];
        [flashbutton setImage:[UIImage imageNamed:@"flash2"] forState:UIControlStateNormal];
        [flashbutton setImage:[UIImage imageNamed:@"flashSelected"] forState:UIControlStateSelected];
        [flashbutton addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:flashbutton];
        
        UIButton *frontcamera = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-50, 5, 47, 25)];
        [frontcamera setImage:[UIImage imageNamed:@"selfieTwo"] forState:UIControlStateNormal];
        [frontcamera addTarget:self action:@selector(showFrontCamera:) forControlEvents:UIControlEventTouchUpInside];
        //[frontcamera setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:frontcamera];
    }
    
    
    UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(5, CGRectGetHeight(self.view.frame)-40, 32, 32)];
    [cancel setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel];
    
    
    
    
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.delegate = self;
    
    self.imageSelectedView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.imageSelectedView setBackgroundColor:[UIColor clearColor]];
    [self.imageSelectedView addSubview:self.capturedImageView];
    
    
    
    UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-60, CGRectGetWidth(self.view.frame), 60)];
    [overlayView setBackgroundColor:[UIColor clearColor]];
    [self.imageSelectedView addSubview:overlayView];
    
    
    
    
    UIButton *selectPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(overlayView.frame)-40, 20, 32, 32)];
    [selectPhotoButton setImage:[UIImage imageNamed:@"postPic.png"] forState:UIControlStateNormal];
    [selectPhotoButton setImage:[UIImage imageNamed:@"postPicSelected.png"] forState:UIControlStateSelected];
    [selectPhotoButton addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:selectPhotoButton];
    
    UIButton *cancelSelectPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 20, 32, 32)];
    [cancelSelectPhotoButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelSelectPhotoButton addTarget:self action:@selector(cancelSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [cancelSelectPhotoButton addTarget:self action:@selector(cancelTextCaption) forControlEvents:UIControlEventTouchUpInside];
    
    [overlayView addSubview:cancelSelectPhotoButton];
    
//    UIButton *album = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-35, CGRectGetHeight(self.view.frame)-40, 27, 27)];
//    [album setImage:[UIImage imageNamed:@"PKImageBundle.bundle/library"] forState:UIControlStateNormal];
//    [album addTarget:self action:@selector(showalbum:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:album];
    
    
    
    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    imageViewTap.delegate = (id) self;
    
    imageViewTap.numberOfTapsRequired = 1;
    imageViewTap.numberOfTouchesRequired = 1;
    
    [self.capturedImageView addGestureRecognizer:imageViewTap];
    
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
    [self.capturedImageView addGestureRecognizer:drag];
    
    
    self.filterSwitcherView = [[SCSwipeableFilterView alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      [[UIScreen mainScreen] bounds].size.width,
                                                                                      [[UIScreen mainScreen] bounds].size.height)];
    
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipe.delegate = (id)self;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(methodToShowViewOnTop)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    self.context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    
    
}

-(void)methodToShowViewOnTop{
    
    // code that puts the view on top
    NSLog(@"ACTIVE");
    
    self.selectedImage = nil;
    
    [self.captureSession startRunning];
    
    [self reloadInputViews];

    
    //////**********************
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self methodToShowViewOnTop];
    
    [self.captureSession startRunning];
    
    NSLog(@"VIEW WILL APPEAR");
    [super viewWillAppear:animated];
    
    [ProgressHUD dismiss];
    
    self.selectedImage = nil;
    
    //[self.captureSession startRunning];
    
    
    [self reloadInputViews];
    
    [self.filterSwitcherView setFilterGroups:nil];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationItem.hidesBackButton = YES;

    
    
    ////////////
//    self.captureSession = [[AVCaptureSession alloc]init];

    
    
}


-(void)viewWillDisappear:(BOOL)animated {
    
    [self.captureSession stopRunning];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.navigationController.navigationBar.hidden = NO;

}




- (void) handleSwipe:(id)sender {
    
    NSLog(@"got swipe");
    
    
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;
    
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        
        NSLog(@"SWIPEE");

        HomeTableViewController *hvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
        hvc.userLocation = self.userLocation;
        [self.navigationController pushViewController:hvc animated:NO];
        
        
        
    }
    
    
    
}



- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer {
    
    NSLog(@"Tap tap");
    //Do stuff here...
    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    
    
    if([caption isFirstResponder]){
        
        [caption resignFirstResponder];
        caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
        
    } else {
        
        if (caption.alpha == 1) {
            
        }
        else {
            
            [self initCaption];
            [caption becomeFirstResponder];
            caption.alpha = 1;
            
        }
    }
    
    
}

-(void)cancelTextCaption {
    
    NSLog(@"canceledd");
    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
    
    //    self.caption.text = nil;
    //
    //    caption = nil;
    
    
    
    [self.caption.text isEqualToString:@""];
    
    [caption resignFirstResponder];
    
}

- (void) initCaption{
    
    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
    
    
    // Caption
    caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.capturedImageView.frame.size.height/2,self.capturedImageView.frame.size.width,32)];
    caption.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    caption.textAlignment = NSTextAlignmentCenter;
    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    caption.textColor = [UIColor whiteColor];
    caption.keyboardAppearance = UIKeyboardAppearanceDark;
    caption.alpha = 0;
    caption.tintColor = [UIColor whiteColor];
    caption.delegate = self;
    [self.capturedImageView addSubview:caption];
    
    
    
}

////STORING CAPTION LOCATION ****************

- (void) captionDrag: (UIGestureRecognizer*)gestureRecognizer{
    
    //NSLog(@"draggggg");
    CGPoint translation = [gestureRecognizer locationInView:self.view];
    
    self.captionLocation = [NSArray arrayWithObjects:
                            [NSValue valueWithCGPoint:translation],
                            nil];
    
    
    NSLog(@"%@", self.captionLocation);
    
    if(translation.y < caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  caption.frame.size.height/2);
    } else if(self.capturedImageView.frame.size.height < translation.y + caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  self.capturedImageView.frame.size.height - caption.frame.size.height/2);
    } else {
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  translation.y);
    }
}
////STORING CAPTION LOCATION ****************




- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string{
    
    NSString *text = textField.text;
    text = [text stringByReplacingCharactersInRange:range withString:string];
    CGSize textSize = [text sizeWithAttributes: @{NSFontAttributeName:textField.font}];
    //NSLog(@"%@", string);
    
    
    
    return (textSize.width + 50 < textField.bounds.size.width) ? true : false;
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSLog(@"return");
    
    [caption resignFirstResponder];
    return true;
}





-(IBAction)capturePhoto:(id)sender {
    
    self.isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            
            //////IF SELFIE TAKEN
            if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
             
                NSLog(@"selfie was taken");
                
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                UIImage *capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
                self.isCapturingImage = NO;
                self.capturedImageView.image = capturedImage;
                
                UIImage * flippedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationLeftMirrored];
                
                
                
                [self.view addSubview:self.imageSelectedView];
                self.selectedImage = flippedImage;
                
                [self.filterSwitcherView setImageByUIImage:self.selectedImage];
                [self.capturedImageView addSubview:self.filterSwitcherView];
                [self.filterSwitcherView setNeedsDisplay];
                [self.filterSwitcherView setNeedsLayout];
                
                
                self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
                self.filterSwitcherView.filterGroups = @[
                                                         [NSNull null],
                                                         [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTransfer"]],
                                                         
                                                         [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]],
                                                         
                                                         [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTonal"]]
                                                         ];
                
                
                [self.capturedImageView addSubview:self.filterSwitcherView];
                [self.filterSwitcherView setNeedsDisplay];
                [self.filterSwitcherView setNeedsLayout];
                
                
                NSLog(@"DDDDisplay %@", self.filterSwitcherView);
                
                
                
                
                imageData = nil;

                
                
                
                
            }
            
            
            else {
            
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
            self.isCapturingImage = NO;
            self.capturedImageView.image = capturedImage;
            
            
            
            
            
            [self.view addSubview:self.imageSelectedView];
            self.selectedImage = capturedImage;

            
            [self.filterSwitcherView setImageByUIImage:self.selectedImage];
            [self.capturedImageView addSubview:self.filterSwitcherView];
            [self.filterSwitcherView setNeedsDisplay];
            [self.filterSwitcherView setNeedsLayout];
            
            self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
            self.filterSwitcherView.filterGroups = @[
                                                     [NSNull null],
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTransfer"]],
                                                     
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]],
                                                     
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectNoir"]]
                                                     ];
            
            
            [self.capturedImageView addSubview:self.filterSwitcherView];
            [self.filterSwitcherView setNeedsDisplay];
            [self.filterSwitcherView setNeedsLayout];
            
            
            NSLog(@"DDDDisplay %@", self.filterSwitcherView);
            
            
            
            
            imageData = nil;
                
            }
            
        }
    }];
    
}



////// DRAWING FILTER & CAPTION OVER PHOTO ****************

-(IBAction)photoSelected:(id)sender {
    
    [ProgressHUD show:nil Interaction:NO];
    NSLog(@"photo selected");
    
    [CATransaction begin];
    HomeTableViewController *hvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    hvc.userLocation = self.userLocation;
    [self.navigationController pushViewController:hvc animated:NO];
    [CATransaction setCompletionBlock:^{
        //whatever you want to do after the push
        
        ///////////////Draw Filter Over Image
        
        UIImage *filteredImage = [self.filterSwitcherView currentlyDisplayedImageWithScale:self.selectedImage.scale orientation:self.selectedImage.imageOrientation];
        
        self.selectedImage = filteredImage;
        
        ///////////////End Filter Drawing
        
        
        
        
        UIGraphicsBeginImageContextWithOptions(self.selectedImage.size, YES, 0.0);
        [self.selectedImage drawInRect:CGRectMake(0,0,self.selectedImage.size.width,self.selectedImage.size.height)];
        
        
        CGPoint myPoint = caption.center;
        
        //CGRect rect = CGRectMake(0, myPoint.y * 4.85, self.selectedImage.size.width, 165);
        
        //CGRect i6LowRect = CGRectMake(0, myPoint.y * 1.75, self.selectedImage.size.width, 80);
        
        
        
        
        //FOR SELFIES
        if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
            
            
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                if([UIScreen mainScreen].bounds.size.height <= 568.0) {
                    
                    if ([self.caption.text length] >= 1) {
                        
                        NSLog(@"iPhone 4");
                        
                        UILabel *capLabel = [[UILabel alloc] init];
                        capLabel.textColor = [UIColor whiteColor];
                        capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
                        capLabel.font = [UIFont systemFontOfSize:18];
                        capLabel.text = self.caption.text;
                        capLabel.numberOfLines = 1;
                        [capLabel setTextAlignment:NSTextAlignmentCenter];
                        [capLabel setNeedsDisplay];
                        [capLabel setNeedsLayout];
                        
                        [capLabel setBounds:CGRectMake(0, myPoint.y * 1.25, self.selectedImage.size.width, 34)];
                        
                        [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
                        
                    }
                    
                    
                }
                
                

            else {
            
            
            //iPhone 6
            if ([self.caption.text length] >= 1) {
                
            UILabel *capLabel = [[UILabel alloc] init];
            capLabel.textColor = [UIColor whiteColor];
            capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            capLabel.font = [UIFont systemFontOfSize:34];
            capLabel.text = self.caption.text;
            capLabel.numberOfLines = 1;
            [capLabel setTextAlignment:NSTextAlignmentCenter];
            [capLabel setNeedsDisplay];
            [capLabel setNeedsLayout];
            
            [capLabel setBounds:CGRectMake(0, myPoint.y * 1.75, self.selectedImage.size.width, 64)];
            
            [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
                
                    }

                 }
            }
        }
        
        
        /////NOT SELFIES
        else {
            
            
        ////IPHONE 4
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if([UIScreen mainScreen].bounds.size.height <= 568.0) {
                
                if ([self.caption.text length] >= 1) {
                    
                    NSLog(@"iPhone 4");
                    
                    UILabel *capLabel = [[UILabel alloc] init];
                    capLabel.textColor = [UIColor whiteColor];
                    capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
                    capLabel.font = [UIFont systemFontOfSize:34];
                    capLabel.text = self.caption.text;
                    capLabel.numberOfLines = 1;
                    [capLabel setTextAlignment:NSTextAlignmentCenter];
                    [capLabel setNeedsDisplay];
                    [capLabel setNeedsLayout];
                    
                    [capLabel setBounds:CGRectMake(0, myPoint.y * 2.15, self.selectedImage.size.width, 58)];
                    
                    [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
                    
                }
                
                
            }
            
            else {
        
                //IPHONE 6^
                if ([self.caption.text length] >= 1) {

                    
                    UILabel *capLabel = [[UILabel alloc] init];
                    capLabel.textColor = [UIColor whiteColor];
                    capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
                    capLabel.font = [UIFont systemFontOfSize:51]; //92
                    capLabel.text = self.caption.text;
                    capLabel.numberOfLines = 1;
                    [capLabel setTextAlignment:NSTextAlignmentCenter];
                    [capLabel setNeedsDisplay];
                    [capLabel setNeedsLayout];
                    
                    [capLabel setBounds:CGRectMake(0, myPoint.y * 2.75, self.selectedImage.size.width, 90)];  // was rect
                    
                    [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
                    
                    NSLog(@"Caption: %@", capLabel.layer);
                    
                }
                
            }
            
        }
    
        
        }
        
        //// IF SELFIE
        if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
            
            /// ON IPHONE 4 -- REDRAW CORRECT SIZE
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                if([UIScreen mainScreen].bounds.size.height <= 568.0) {
                    
                    NSLog(@"NEW IFFFFFF BABY");
                    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();

                    
                    UIImage *finalImage = myNewImage;
                    
                    
                    if (finalImage.size.width > 140) finalImage = ResizeImage(finalImage, 240, 320);
                    
                    NSData *imageData = UIImagePNGRepresentation(finalImage);
                    [self uploadImage:imageData];

                }
                
                else {
                    
                    
                    NSLog(@"Sefie iPhone 6");
                    
                    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    
                    UIImage *finalImage = myNewImage;
                    
                    
                    if (finalImage.size.width > 140) finalImage = ResizeImage(finalImage, 225, 400); //300x400-240x430-225x400
                    
                    
                    
                    // Upload image******************************************
                    
                    NSData *imageData = UIImagePNGRepresentation(finalImage);
                    [self uploadImage:imageData];
                    
                    
                    
                    
                }

            }
            
        }
        
        
        else {
        
        
        UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIImage *finalImage = myNewImage;
        
        
        if (finalImage.size.width > 140) finalImage = ResizeImage(finalImage, 225, 400); //300 x 400 -- 240 x 430
            
        
        
        // Upload image******************************************
        
        NSData *imageData = UIImagePNGRepresentation(finalImage);
        [self uploadImage:imageData];
        
        }
        
        self.caption.text = nil;
        caption = nil;
        
        
    }];
    [CATransaction commit];
    
    
    
    
}

////// DRAWING FILTER & CAPTION OVER PHOTO ****************





//*********************************************
// Resize the Image Properly

UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height) {
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//*********************************************





- (void)uploadImage:(NSData *)imageData {
    
    [self.imageSelectedView removeFromSuperview];
    
    
    NSString *fileName = @"image.png";
    
    NSString *fileType = fileType = @"image";
    
    
    fileName = @"image.png";
    fileType = @"image";
    
    
    
    PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
    
    [ProgressHUD show:nil];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            
            PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            //[userPhoto setObject:thePhotoCaption forKey:@"photoCaption"];
            [userPhoto setObject:self.userLocation forKey:@"postLocation"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    NSLog(@"Succeeeeeded");
                    [ProgressHUD dismiss];
                    
                    //[self.imageSelectedView removeFromSuperview];
                    
                }
                else {
                    
                    [ProgressHUD showError:@"Network Error"];
                    
                }
            }];
        }
    }];
}





-(IBAction)flash:(UIButton*)sender {
    NSLog(@"flash");
    
    if ([self.captureDevice isFlashAvailable]) {
        if (self.captureDevice.flashActive) {
            if([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOff;
                [sender setTintColor:[UIColor grayColor]];
                [sender setSelected:NO];
            }
        }
        else {
            if([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOn;
                [sender setTintColor:[UIColor blueColor]];
                [sender setSelected:YES];
            }
        }
        [self.captureDevice unlockForConfiguration];
    }
}

-(IBAction)showFrontCamera:(id)sender {
    NSLog(@"selfie cam");
    
    if (self.isCapturingImage != YES) {
        if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
            // rear active, switch to front
            NSLog(@"SELFIE TIME");
            self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
            
            [self.captureSession beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
            for (AVCaptureInput * oldInput in self.captureSession.inputs) {
                NSLog(@"Selfie action aclled");
                [self.captureSession removeInput:oldInput];
                
            }
            [self.captureSession addInput:newInput];
            [self.captureSession commitConfiguration];
        }
        else if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
            // front active, switch to rear
            self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
            [self.captureSession beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
            for (AVCaptureInput * oldInput in self.captureSession.inputs) {
                [self.captureSession removeInput:oldInput];
            }
            [self.captureSession addInput:newInput];
            [self.captureSession commitConfiguration];
        }
        
        // Need to reset flash btn
    }
}
-(IBAction)showalbum:(id)sender
{
    [self presentViewController:self.picker animated:NO completion:nil];
    //
}





-(IBAction)cancelSelectedPhoto:(id)sender {
    
    self.caption.text = nil;
    
    caption = nil;
    
    NSLog(@"Cancelled Filters");
    
    
    [self.filterSwitcherView setFilterGroups:nil];
    
    
    
    
    [self.imageSelectedView removeFromSuperview];
    
    
}

-(IBAction)cancel:(id)sender {
    
    self.caption.text = nil;
    
    caption = nil;
    //NSLog(@"should Pop Home");
    
    
    
    HomeTableViewController *hvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    hvc.userLocation = self.userLocation;
    [self.navigationController pushViewController:hvc animated:NO];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"did finish");
    
    [self dismissViewControllerAnimated:NO completion:^{
        self.capturedImageView.image = self.selectedImage;
        NSLog(@"didFinish blah blah blah");
        [self.view addSubview:self.imageSelectedView];
        
        
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}




///************ Start downloading images

- (PFQuery *)queryForTable {
    
    if (!self.userLocation) {
        NSLog(@"nilllll");
        
        return nil;
    }
    
    NSLog(@"Refreshing");
    //PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    
    self.imageQuery = [PFQuery queryWithClassName:@"UserPhoto"];
    
    [imageQuery setLimit: 100];
    [imageQuery orderByAscending:@"createdAt"];
    [imageQuery whereKey:@"postLocation" nearGeoPoint:self.userLocation withinMiles:7];
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            NSLog(@"error");
        }
        else {
            
            
            for (PFObject *object in objects) {
                PFFile *file = [object objectForKey:@"imageFile"];
                
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        

                        [imageQuery cancel];
                        
                        
                    }
                    
                } progressBlock:^(int percentDone) {
                    
                    
                }];
            }
        }
    }];
    
    return nil;
    
}




@end
