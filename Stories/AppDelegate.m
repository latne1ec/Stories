//
//  AppDelegate.m
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <AWSCore/AWSCore.h>



#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]




@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [Parse setApplicationId:@"UaGnyAmcvVo2aDaCaHf0bnNm0c5IyjyiSCSip75i"
                  clientKey:@"CR1zqHWJ8FdsZWgf43IjSJbxuckMT83UZRCS7Kba"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFImageView class];
    
    
    
    //[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xeeeded)];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.871 green:0.278 blue:0.278 alpha:1]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1]];
    
    
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation.png"]
                                       //forBarMetrics:UIBarMetricsDefault];
    
    
    
    
    
    //21201f
    //eeeded
//    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        
        NSLog(@"iPhone 4 or 5");
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AvenirNext-DemiBold" size:25], NSFontAttributeName, nil]];
        
        
        
    }
    
    else {
        
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.922 green:0.322 blue:0.322 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AvenirNext-DemiBold" size:26], NSFontAttributeName, nil]];
        
    }
    

    //colorWithRed:0.867 green:0.243 blue:0.243 alpha:1] -- red color
    //colorWithRed:0.141 green:0.129 blue:0.129 alpha:1] -- black color
    
    
    self.swipeBetweenVC = [YZSwipeBetweenViewController new];
    [self setupRootViewControllerForWindow];
    self.window.rootViewController = self.swipeBetweenVC;
    
    [self.window makeKeyAndVisible];
    
    
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:071bc929-229a-4a61-8e99-063d4b14083e"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                         credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;

    
    return YES;
}

- (void)setupRootViewControllerForWindow {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navCon1 = [storyboard instantiateViewControllerWithIdentifier:@"VideoCamNav"];
    UINavigationController *navCon2 = [storyboard instantiateViewControllerWithIdentifier:@"StoriesNav"];
    //UINavigationController *navCon3 = [storyboard instantiateViewControllerWithIdentifier:@"ViewStoryNav"];
    //UINavigationController *navCon4 = [storyboard instantiateViewControllerWithIdentifier:@"ViewVideoNav"];
    
    
    
    self.swipeBetweenVC.viewControllers = @[navCon2, navCon1];
    
    
    
    
    
    self.swipeBetweenVC.initialViewControllerIndex = (NSInteger)self.swipeBetweenVC.viewControllers.count/2;
    
    
    
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
//    if ([PFUser currentUser]) {
//        
//        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
//        
//        [navController popToRootViewControllerAnimated:NO];
//        
//    }
// 
//    else {
//        
//        NSLog(@"Not a user yet");
//    }
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
