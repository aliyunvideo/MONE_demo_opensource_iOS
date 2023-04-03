//
//  AUIVideoStandradScrollView.h
//  AUIVideoList
//
//  Created by zzy on 2023/3/7.
//  Copyright © 2023年 com.alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUIVideoInfo.h"

@class AUIVideoStandradScrollView;

@protocol AUIVideoStandradScrollViewDelegate <NSObject>

@optional
/**
 全屏点击事件

 @param scrollView scrollView
 */
- (void)tapGestureAction:(AUIVideoStandradScrollView *)scrollView;

/**
 滚动事件,移动位置超过一个
 
 @param scrollView scrollView
 @param index 移动到第几个
 */
- (void)scrollView:(AUIVideoStandradScrollView *)scrollView didEndDeceleratingAtIndex:(NSInteger)index;

/**
 移动到下一个

 @param scrollView scrollView
 @param index 第几个
 */
- (void)scrollView:(AUIVideoStandradScrollView *)scrollView motoNextAtIndex:(NSInteger)index;

/**
 移动到上一个

 @param scrollView scrollView
 @param index 第几个
 */
- (void)scrollView:(AUIVideoStandradScrollView *)scrollView motoPreAtIndex:(NSInteger)index;

/**
 当前播放视图准备滑动

 @param scrollView scrollView
 */
- (void)scrollViewWillBeginDragging:(AUIVideoStandradScrollView *)scrollView;

/**
 当前播放视图移除屏幕

 @param scrollView scrollView
 */
- (void)scrollViewScrollOut:(AUIVideoStandradScrollView *)scrollView;

@end

@interface AUIVideoStandradScrollView : UIView

/**
 代理
 */
@property (nonatomic,weak) id <AUIVideoStandradScrollViewDelegate> delegate;

/**
 滚动视图当前位置
 */
@property (nonatomic,assign)NSInteger currentIndex;

/**
 是否显示中间的播放按钮
 */
@property (nonatomic,assign)BOOL showPlayImage;

/**
 播放的视图
 */
@property (nonatomic,strong)UIView *playView;

/**
 展示播放视图
 */
- (void)showPlayView;

- (UIScrollView *)getScrollView;

/**
 更新数据源

 @param sources 数据源
 @param add 是否是追加数据源
 */
- (void)updateSources:(NSArray <AUIVideoInfo *>*)sources add:(BOOL)add;

/**
 滑动数据
 
 @param index 滑动源数据下标
 @param duration 滑动时间
 */
- (void)moveScrollAtIndex:(NSInteger)index duration:(float)duration;

@end






