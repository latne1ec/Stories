//
//  AppDelegate.h
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeViewController.h"
#import "StoriesTableViewController.h"
#import "StoriesNavController.h"
#import "YZSwipeBetweenViewController.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) YZSwipeBetweenViewController *swipeBetweenVC;

- (void)setupRootViewControllerForWindow;


@end

