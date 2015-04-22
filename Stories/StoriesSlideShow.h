//
//  StoriesSlideShow.h
//  Stories
//
//  Created by Evan Latner on 3/20/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StoriesSlideShowTransitionType) {
    StoriesSlideShowTransitionFade,
    StoriesSlideShowTransitionSlide
};

typedef NS_ENUM(NSUInteger, StoriesSlideShowPosition) {
    StoriesSlideShowPositionTop,
    StoriesSlideShowPositionBottom
};

typedef NS_ENUM(NSUInteger, StoriesSlideShowState) {
    StoriesSlideShowStateStopped,
    StoriesSlideShowStateStarted
};


@class StoriesSlideShow;
@protocol StoriesSlideShowDelegate <NSObject>
@optional
- (void) storiesSlideShowDidNext:(StoriesSlideShow *) slideShow;
- (void) storiesSlideShowDidPrevious:(StoriesSlideShow *) slideShow;
- (void) storiesSlideShowWillShowNext:(StoriesSlideShow *) slideShow;
- (void) storiesSlideShowWillShowPrevious:(StoriesSlideShow *) slideShow;
@end

@protocol StoriesSlideShowDataSource <NSObject>
- (UIImage *)slideShow:(StoriesSlideShow *)slideShow imageForPosition:(StoriesSlideShowPosition)position;
@end


@interface StoriesSlideShow : UIView

@property (nonatomic, unsafe_unretained) IBOutlet id <StoriesSlideShowDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<StoriesSlideShowDataSource> dataSource;

@property  float delay;
@property  float transitionDuration;
@property  (readonly, nonatomic) NSUInteger currentIndex;
@property  (atomic) StoriesSlideShowTransitionType transitionType;
@property  (atomic) UIViewContentMode imagesContentMode;
@property  (strong,nonatomic) NSMutableArray * images;
@property  (readonly, nonatomic) StoriesSlideShowState state;


- (void) addImagesFromResources:(NSArray *) names;
- (void) emptyAndAddImagesFromResources:(NSArray *)names;
- (void) setImagesDataSource:(NSMutableArray *)array;
- (void) addImage:(UIImage *) image;
- (void) next;


@end
