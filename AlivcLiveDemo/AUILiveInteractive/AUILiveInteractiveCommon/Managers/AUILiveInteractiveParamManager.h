//
//  AUILiveInteractiveParamManager.h
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/8/31.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AUILiveInteractiveURLConfigType) {
    AUILiveInteractiveURLConfigTypeLinkMic = 0, // 连麦互动
    AUILiveInteractiveURLConfigTypePK,          // PK互动
};

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveInteractiveParamManager : NSObject

/**
 分辨率
 * 默认 : AlivcLivePushResolution540P
 */
@property (nonatomic, assign) AlivcLivePushResolution resolution;

/**
 视频编码模式
 * 默认 : AlivcLivePushVideoEncoderModeHard
 */
@property (nonatomic, assign) AlivcLivePushVideoEncoderMode videoEncoderMode;

/**
 音频编码模式
 * 默认 : AlivcLivePushAudioEncoderModeHard
 */
@property (nonatomic, assign) AlivcLivePushAudioEncoderMode audioEncoderMode;

/**
 纯音频推流
 * 默认 : NO，不开启
 */
@property (nonatomic, assign) bool audioOnly;

/**
 关键帧间隔
 * 默认 : AlivcLivePushVideoEncodeGOP_2
 * 单位 : s
 */
@property (nonatomic, assign) AlivcLivePushVideoEncodeGOP videoEncodeGop;

/**
 视频硬编码方式 （当videoEncoderMode设置为AlivcLivePushVideoEncoderModeHard时，有两种可选的视频硬件编码方式：H264和HEVC(H265)）
 * 默认：AlivcLivePushVideoEncoderModeHardCodecH264，使用H264进行硬件编码
 */
@property (nonatomic, assign) AlivcLivePushVideoEncoderModeHardCodec videoHardEncoderCodec;

/**
 选择开启外部音视频推流
 * 默认 : NO，不开启
 */
@property (nonatomic, assign) BOOL isUserMainStream;

/**
 视频采集帧率
 * 默认 : AlivcLivePushFPS20
 */
@property (nonatomic, assign) AlivcLivePushFPS fps;

/**
 打开美颜
 * 默认：YES
 */
@property (nonatomic, assign) BOOL beautyOn;

+ (instancetype)manager;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
