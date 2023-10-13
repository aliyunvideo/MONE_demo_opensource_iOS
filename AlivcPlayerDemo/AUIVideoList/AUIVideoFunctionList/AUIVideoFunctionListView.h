//
//  AUIVideoFunctionListView.h
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/11/9.
//

#import "AVBaseViewController.h"
#import "AUIVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoFunctionListView : AVBaseViewController

/**
 添加数据源
 @param sources 数据源数组数据，格式@[AUIVideoInfo,AUIVideoInfo,...]
 */
- (void)loadSources:(NSArray<AUIVideoInfo *> *)sources;

/**
 追加加数据源
 @param sources 数据源数组数据，格式@[AUIVideoInfo,AUIVideoInfo,...]
 */
- (void)addSources:(NSArray<AUIVideoInfo *> *)sources;

/**
 主动调用切换到指定的某个列表下标播放
 @param index 指定的某个列表下标
 */
- (void)moveToPlayAtIndex:(int)index;

/**
 是否开启页面上的播放进度条
 @param open 是否开启。默认开启
 */
- (void)showPlayProgressBar:(BOOL)open;

/**
 是否开启页面上的播放标题展示文案
 @param open 是否开启。默认开启
 */
- (void)showPlayTitleContent:(BOOL)open;

/**
 是否开启屏幕上点击切换播放状态暂停/继续
 @param open 是否开启。默认开启
 */
- (void)showPlayStatusTapChange:(BOOL)open;

/**
 是否开启自动单个视频循环播放
 @param open 是否开启。默认开启。需要在开启画面前调用。
 */
- (void)openLoopPlay:(BOOL)open;

/**
 是否开启自动切换到下一个播放。需要在openLoopPlay:关闭的基础上开启或关闭。
 @param open 是否开启。默认关闭。需要在开启画面前调用。
 */
- (void)autoPlayNext:(BOOL)open;

/**
 刷新请求数据
 @param url 请求数据的URL地址
 @param completion 请求结束回调数据，success：是否成功，sources：成功后的数据源数组数据，格式@[AUIVideoInfo,AUIVideoInfo,...]，error：请求失败的描述
 */
- (void)reloadData:(NSString *)url completion:(nullable void(^)(BOOL success, NSArray<AUIVideoInfo *> *sources, NSError *error))completion;

/**
 加载更多请求数据
 @param url 请求数据的URL地址
 @param completion 请求结束回调数据，success：是否成功，sources：成功后的数据源数组数据，格式@[AUIVideoInfo,AUIVideoInfo,...]，nextIndex: 下一页标识，error：请求失败的描述
 */
- (void)loadMoreData:(NSString *)url nextIndex:(id)nextIndex completion:(nullable void(^)(BOOL success, NSArray<AUIVideoInfo *> *sources, id nextIndex, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
