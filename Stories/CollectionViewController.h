//
//  CollectionViewController.h
//  Spotshot
//
//  Created by Evan Latner on 4/9/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "CollectionViewCell.h"
//#import "ViewVideoViewController.m"

@interface CollectionViewController : UICollectionViewController

@property (nonatomic, strong) UITapGestureRecognizer *tapTap;

@property (nonatomic, strong) NSArray *stories;


@end
