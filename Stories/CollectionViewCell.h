//
//  CollectionViewCell.h
//  Spotshot
//
//  Created by Evan Latner on 4/9/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *displayImage;
@property (nonatomic, strong) NSString *picUrl;

@end
