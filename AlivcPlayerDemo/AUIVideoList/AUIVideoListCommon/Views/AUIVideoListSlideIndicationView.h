//
//  AUIVideoListSlideIndicationView.h
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoListSlideIndicationView : UIView

- (instancetype)initOnView:(UIView *)view;
- (void)updateShowStatus:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
