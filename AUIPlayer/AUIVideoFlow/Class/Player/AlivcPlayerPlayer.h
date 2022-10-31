//
//  AlivcPlayerPlayer.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/8.
//

#import <Foundation/Foundation.h>
#import <AliyunPlayer/AVPDef.h>


@protocol AlivcPlayerPlayer <NSObject>

/**
 @brief 开始播放
 */
- (void)startPlayWithVid:(NSString *)vid;

/**
 @brief 暂停播放
 */
- (void)pause;

/**
 @brief 继续播放
 */
- (void)resume;

/**
 @brief 停止播放
 */
- (void)stop;

- (void)clearScreen;

/**
 @brief 跳转
 */
- (void)seekToTimeProgress:(CGFloat)progress seekMode:(AVPSeekMode)seekMode;

/**
 @brief 获取缩略图
 */
-(void)getThumbnail:(CGFloat)progress;

/**
 @brief 时长,毫秒
 */
- (int64_t)duration;


- (int64_t)currentPosition;


- (AVPMediaInfo *)getMediaInfo;

-(AVPTrackInfo*) getCurrentTrack:(AVPTrackType)type;

-(void)selectTrack:(AVPTrackInfo *)info;


@property(nonatomic) float rate;

@property (nonatomic, assign) float volume;



@property (nonatomic, copy, readonly) NSString *currentVideoId;

@property (nonatomic, assign, readonly) AVPStatus playerStatus;

@property (nonatomic, assign, readonly) AVPEventType playerEventType;

//是否关闭视频流
@property (nonatomic, assign) BOOL disableVideo;

@end


