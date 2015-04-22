//
//  StoriesSlideShow.m
//  Stories
//
//  Created by Evan Latner on 3/20/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "StoriesSlideShow.h"

@interface StoriesSlideShow()
@property (atomic) BOOL doStop;
@property (atomic) BOOL isAnimating;
@property (strong,nonatomic) UIImageView * topImageView;
@property (strong,nonatomic) UIImageView * bottomImageView;

@end


@implementation StoriesSlideShow


@synthesize delegate;
@synthesize delay;
@synthesize transitionDuration;
@synthesize transitionType;
@synthesize images;

- (void)awakeFromNib
{
    [self setDefaultValues];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _topImageView.frame = frame;
    _bottomImageView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(self.bounds, _topImageView.bounds)) {
        _topImageView.frame = self.bounds;
    }
    
    if (!CGRectEqualToRect(self.bounds, _bottomImageView.bounds)) {
        _bottomImageView.frame = self.bounds;
    }
}

- (void) setDefaultValues
{
    self.clipsToBounds = YES;
    self.images = [NSMutableArray array];
    _currentIndex = 0;
    delay = 3;
    
    transitionDuration = 1;
    _doStop = YES;
    _isAnimating = NO;
    
    _topImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _bottomImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _topImageView.autoresizingMask = _bottomImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _topImageView.clipsToBounds = YES;
    _bottomImageView.clipsToBounds = YES;
    [self setImagesContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:_bottomImageView];
    [self addSubview:_topImageView];
}

- (void) setImagesContentMode:(UIViewContentMode)mode
{
    _topImageView.contentMode = mode;
    _bottomImageView.contentMode = mode;
}

- (UIViewContentMode) imagesContentMode
{
    return _topImageView.contentMode;
}

- (void) addImagesFromResources:(NSArray *) names
{
    for(NSString * name in names){
        [self addImage:[UIImage imageNamed:name]];
    }
}

- (void) setImagesDataSource:(NSMutableArray *)array {
    self.images = array;
    
    
    _topImageView.image = [array firstObject];
}

- (void) addImage:(UIImage*) image
{
    [self.images addObject:image];
    
    if([self.images count] == 1){
        _topImageView.image = image;
    }else if([self.images count] == 2){
        _bottomImageView.image = image;
    }
}

- (void) emptyAndAddImagesFromResources:(NSArray *)names
{
    [self.images removeAllObjects];
    _currentIndex = 0;
    [self addImagesFromResources:names];
}

- (void) start
{
    _doStop = NO;
    [self next];
}

- (void) next {
    
    if(! _isAnimating && ([self.images count] >1 || self.dataSource)) {
        
        if ([self.delegate respondsToSelector:@selector(storiesSlideShowWillShowNext:)]) [self.delegate storiesSlideShowWillShowNext:self];
        
        // Next Image
        if (self.dataSource) {
            _topImageView.image = [self.dataSource slideShow:self imageForPosition:StoriesSlideShowPositionTop];
            _bottomImageView.image = [self.dataSource slideShow:self imageForPosition:StoriesSlideShowPositionBottom];
        } else {
            NSUInteger nextIndex = (_currentIndex+1)%[self.images count];
            _topImageView.image = self.images[_currentIndex];
            _bottomImageView.image = self.images[nextIndex];
            _currentIndex = nextIndex;
        }
        
        
        // Call delegate
        if([delegate respondsToSelector:@selector(storiesSlideShowDidNext:)]){
            [delegate storiesSlideShowDidNext:self];
        }
    }
}


@end
