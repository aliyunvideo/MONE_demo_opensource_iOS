//
//  AUIVideoListDataManager.h
//  AUIVideoList
//
//  Created by zzy on 2022/3/23.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUIVideoInfo.h"

@interface AUIVideoListDataManager : NSObject

// 保存的请求URL
@property (nonatomic, copy) NSString *requestUrl;
// 下一页的标识，用在加载更多数据请求
@property (nonatomic, copy) id nextIndex;

/**
 请求数据
 @param isAdd 是否加载更多数据
 @param completion 请求结束回调。success：是否请求成功，sources：转换后的数据，errorMsg：错误信息
 */
- (void)requestVideoInfos:(BOOL)isAdd completion:(void(^)(BOOL success, NSArray<AUIVideoInfo *> *sources, NSError *error))completion;

/**
 转化Json数组为标准数组数据
 @param data Json数组数据
 */
- (NSArray<AUIVideoInfo *> *)convertSourceData:(NSArray<NSDictionary *> *)data;
/**
 获取app对外json数据
 */
+ (NSArray<NSDictionary *> *)getDefaultJsonSourceData;

/**
 页面是否显示上滑手势。每个页面只显示一次。
 @param pageName 页面名称
 */
+ (BOOL)isSlideIndicationShow:(NSString *)pageName;
/**
 更新页面显示上滑手势状态。
 @param isShow 是否显示
 @param pageName 页面名称
 */
+ (void)updateSlideIndicationShow:(BOOL)isShow pageName:(NSString *)pageName;

@end
