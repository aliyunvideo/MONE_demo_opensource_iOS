//
//  AlivcPlayerListPlayer.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/9.
//

#import <Foundation/Foundation.h>


@protocol AlivcPlayerListPlayer <NSObject>

/**
 @brief 将播放源添加进播放列表 uid播放的唯一标识 uuid
 */
- (void)addVidSource:(NSString *)vid uuid:(NSString *)uuid;

/**
 @brief 从播放列表移除
 */
- (void)removeSource:(NSString*)uuid;

/**
 @brief 清空全部播放列表
 */
- (void)clear;

/**
 @brief 当前播放的uuid
 */
- (NSString *)currentUuid;

- (BOOL)containVideoId:(NSString *)videoId uuid:(NSString *)uuid;


/**
 播放指定的uuid
 */
- (BOOL)moveToVideoId:(NSString *)videoId uuid:(NSString *)uuid;


- (void)playNext;

- (void)playPre;

- (BOOL)canPlayNext;

- (BOOL)canPlayPre;

- (BOOL)forceRePlaymoveToVideoId:(NSString *)videoId uuid:(NSString *)uuid;


@end

