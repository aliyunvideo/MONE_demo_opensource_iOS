//
//  AUILiveMonitorView.h
//  AliLiveSdk-Demo
//
//  Created by lichentao on 2020/12/23.
//  Copyright © 2020 alilive. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveMonitorView : UIView

//@property (nonatomic, assign) uint32_t sentBitrate;    // 发送码率
//@property (nonatomic, assign) uint32_t sentFps;        // 发送帧率
//@property (nonatomic, assign) uint32_t encodeFps;      // 编码帧率

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *sentBitrateLabel;
@property (nonatomic,strong) UILabel *sentFpsLabel;
@property (nonatomic,strong) UILabel *encodeFpsLabel;

- (id)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
