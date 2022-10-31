//
//  AUIVideoListPlayScrollView.h
//  AliPlayerDemo
//
//  Created by zzy on 2022/3/22.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUIVideoListManager.h"

@class AUIVideoListPlayScrollView;

@protocol AUIVideoListPlayScrollViewDelegate <NSObject>

@optional

/**
 全屏点击事件
 
 @param playScrollView playScrollView
 */
- (void)AUIVideoListPlayScrollViewTapGestureAction:(AUIVideoListPlayScrollView *)playScrollView;

/**
 滚动事件,移动位置超过一个
 
 @param playScrollView playScrollView
 @param index 移动到第几个
 @param motoNext 是否是向下移动
 */
- (void)AUIVideoListPlayScrollView:(AUIVideoListPlayScrollView *)playScrollView scrollViewDidEndDeceleratingAtIndex:(NSInteger)index motoNext:(BOOL)motoNext;

/**
 移动到下一个

 @param playScrollView playScrollView
 @param index 第几个
 */
- (void)AUIVideoListPlayScrollView:(AUIVideoListPlayScrollView *)playScrollView motoNextAtIndex:(NSInteger)index;

/**
 移动到上一个

 @param playScrollView playScrollView
 @param index 第几个
 */
- (void)AUIVideoListPlayScrollView:(AUIVideoListPlayScrollView *)playScrollView motoPreAtIndex:(NSInteger)index;

/**
 当前播放视图移除屏幕

 @param playScrollView playScrollView
 */
- (void)AUIVideoListPlayScrollViewScrollOut:(AUIVideoListPlayScrollView *)playScrollView;

/**
 滑动进度条
 
 @param playScrollView playScrollView
 @param progress 滑动进度
 */
- (void)AUIVideoListPlayScrollViewSliderAction:(AUIVideoListPlayScrollView *)playScrollView progress:(float)progress;

@end

@interface AUIVideoListPlayScrollView : UIView

/**
 代理
 */
@property (nonatomic,weak) id <AUIVideoListPlayScrollViewDelegate> delegate;

/**
 滚动视图当前位置
 */
@property (nonatomic,assign)NSInteger currentIndex;

/**
 滚动视图上一个位置
 */
@property (nonatomic,assign)NSInteger lastIndex;

/**
 播放的视图
 */
@property (nonatomic,strong)UIView *playView;

/**
 是否显示播放图片
 */
@property (nonatomic,assign)BOOL showPlayImage;

/**
 初始化方法

 @param frame frame
 @param array 内容数组
 @return playScrollView
 */
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray<AUIVideoListModel *>*)array;

/**
 展示播放视图
 */
- (void)showPlayView;

/**
 更新进度条
 */
- (void)updateProgress:(int64_t)position duration:(int64_t)duration;

@end
