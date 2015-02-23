//
//  CameraViewController.h
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIImageView.h"
#import "SCSwipeableFilterView.h"
#import "ProgressHUD.h"
#import <Parse/Parse.h>
#import "HomeTableViewController.h"


@protocol PKImagePickerViewControllerDelegate <NSObject>

-(void)imageSelected:(UIImage*)img;
-(void)imageSelectionCancelled;
-(void)theCaption:(NSString *)caption;


@end



@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate>


@property(nonatomic,weak) id<PKImagePickerViewControllerDelegate> delegate;

@property (nonatomic, strong) UITextField *caption;

@property (nonatomic, strong) UILabel *labelCaption;

@property (strong, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;

@property (nonatomic, strong) PFGeoPoint *userLocation;


@property (nonatomic, strong) PFQuery *imageQuery;




@end
