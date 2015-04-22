//
//  LeaderboardTableCell.h
//  Spotshot
//
//  Created by Evan Latner on 4/17/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userPic;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *userScore;


@end
