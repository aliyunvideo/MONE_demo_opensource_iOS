//
//  AUIVideoListPlayStateImageView.h
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoListPlayStateImageView : UIImageView

- (instancetype)initOnView:(UIView *)view image:(nullable UIImage *)image;
- (void)show:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
