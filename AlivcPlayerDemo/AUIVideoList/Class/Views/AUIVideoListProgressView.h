//
//  AUIVideoListProgressView.h
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoListProgressView : UIView

- (void)updateSliderValue:(int64_t)position duration:(int64_t)duration;
- (void)updateCacheProgressValue:(int64_t)position duration:(int64_t)duration;

@end

NS_ASSUME_NONNULL_END
