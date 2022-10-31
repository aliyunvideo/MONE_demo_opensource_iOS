//
//  AUIVideoPreview.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/2.
//

#import "AUIFoundation.h"
#import "AUIVideoPlayProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoPreview : UIView

@property (nonatomic, weak) id<AUIVideoPlayProtocol> player;
@property (nonatomic, strong, readonly) UIView *displayView;
@property (nonatomic, assign) CGSize displayResolution;
@property (nonatomic, assign, readonly) BOOL isFullScreenMode;
@property (nonatomic, copy) void(^onFullScreenModeChanged)(bool isFull);
@property (nonatomic, copy) void(^onDisplayViewLayoutChanged)(void);

- (instancetype)initWithFrame:(CGRect)frame withDisplayResolution:(CGSize)displayResolution;
- (void)enterFullScreen:(UIView *)fullScreenView;
- (void)exsitFullScreen;

@end

NS_ASSUME_NONNULL_END
