//
//  AUIPlayerThumbnailView.h
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AUIPlayerThumbnailStyle) {
    AUIPlayerThumbnailStylePortrait = 0,
    AUIPlayerThumbnailStyleLandscapeHasThumbnail,
    AUIPlayerThumbnailStyleLandscapeWithoutThumbnail,
};

NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerThumbnailView : UIView

@property (nonatomic, assign) AUIPlayerThumbnailStyle style;

- (void)updateThumbnail:(nullable UIImage *)thumbnail positionTimeValue:(int64_t)position duration:(int64_t)duration;

@end

NS_ASSUME_NONNULL_END
