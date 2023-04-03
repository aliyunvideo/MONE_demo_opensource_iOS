//
//  AUIVideoListPlayStateImageView.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import "AUIVideoListPlayStateImageView.h"

@interface AUIVideoListPlayStateImageView ()

@end

@implementation AUIVideoListPlayStateImageView

- (instancetype)initOnView:(UIView *)view image:(nullable UIImage *)image {
    if (self = [super init]) {
        UIImage *playImage = nil;
        if (image) {
            playImage = image;
        } else {
            playImage = AUIVideoListImage(@"player_play");
        }
        self.frame = CGRectMake(0, 0, playImage.size.width, playImage.size.height);
        self.accessibilityIdentifier = AUIVideoListAccessibilityStr(@"playStateImageView");
        self.center = view.center;
        self.image = playImage;
        [view addSubview:self];
    }
    return self;
}

- (void)show:(BOOL)isShow {
    self.hidden = !isShow;
}

@end
