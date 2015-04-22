//
//  CollectionViewController.m
//  Spotshot
//
//  Created by Evan Latner on 4/9/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "CollectionViewController.h"
#import "UIImageView+WebCache.h"


@interface CollectionViewController ()

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Dope");

    [self queryForStories];
    
    self.tapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    self.tapTap.delegate = (id)self;
    self.tapTap.numberOfTapsRequired = 1;
    self.tapTap.numberOfTouchesRequired = 1;
    self.tapTap.delaysTouchesBegan = YES;      //Important to add
    [self.view addGestureRecognizer:self.tapTap];

    
    
}

-(void)handleSingleTap {
 
    
}


#pragma mark - Navigation


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.stories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"Cell";
    
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        NSLog(@"A big fat nillll");
        
    }

    PFObject *object = [self.stories objectAtIndex:indexPath.row];
    cell.picUrl = [object objectForKey:@"awsUrl"];


    
//    NSURL *imageURL = [NSURL URLWithString:cell.picUrl];
//    cell.displayImage = (UIImageView *)[cell viewWithTag:100];
//    [cell.displayImage sd_setImageWithURL:imageURL];
//    placeholderImage:[UIImage imageNamed:@"tableBkg.png"];
//    
    
    PFFile *imagePost = [object objectForKey:@"storyImage"];
    
    PFImageView *ImageView = (PFImageView*)cell.displayImage;
    ImageView.image = [UIImage imageNamed:@"YapHolder"];
    ImageView.file = imagePost;
    [ImageView loadInBackground];
    cell.displayImage.layer.cornerRadius = cell.displayImage.frame.size.width / 2;
    cell.displayImage.clipsToBounds = YES;

    

    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)queryForStories {
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"FeaturedStories"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            NSLog(@"error");
            
        }
        else {
            
            self.stories = objects;
            
            NSLog(@"Stories Count: %lu", (unsigned long)self.stories.count);
            [self.collectionView reloadData];
            
            
        }
        
    }];
    
    
}



@end
