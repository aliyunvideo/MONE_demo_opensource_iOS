//
//  AUILiveDebugTextView.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/10/17.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AUILiveDebugTextView.h"

@interface AUILiveDebugTextView()

@property (nonatomic, strong) UITextView *debugTextView;


@end

@implementation AUILiveDebugTextView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews {
    
    self.debugTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.frame) - 40, CGRectGetHeight(self.frame) - 40)];
    self.debugTextView.textColor = [UIColor redColor];
    self.debugTextView.backgroundColor = [UIColor clearColor];
    self.debugTextView.font = [UIFont fontWithName:@"Arial" size:14.0];
    [self.debugTextView setEditable:NO];
    [self addSubview:self.debugTextView];

}


- (void)updateData:(AlivcLivePushStatsInfo *)info {
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];

    [mutableString appendString:[NSString stringWithFormat:@"\n%@:\n\n", AUILiveCameraPushString(@"推流参数log")]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %.2f%%\n", AUILiveCameraPushString(@"当前CPU："), info.CPUHold]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %.2fMB\n\n", AUILiveCameraPushString(@"当前Memory："), info.memoryHold]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"视频采集帧率："), info.videoCaptureFps]];
    
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"音频编码码率："), info.audioEncodedBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"音频编码帧率："), info.audioEncodedFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"音频编码器队列中帧缓存数："), info.audioFramesInEncodeBuffer]];
    
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"视频渲染帧率："), info.videoRenderFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"渲染队列中帧缓存数："), info.videoFramesInRenderBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d ms\n", AUILiveCameraPushString(@"每帧平均渲染时长："), info.videoRenderConsumingTimePerFrame]];

//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"视频编码码率："), info.videoEncodedBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"视频编码器队列中帧缓存数："), info.videoFramesInEncodeBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"视频编码帧率："), info.videoEncodedFps]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"视频编码总帧数："), info.totalFramesOfEncodedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"视频编码总耗时："), info.totalTimeOfEncodedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"视频编码器设置码率："), info.videoEncodeParam]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %@\n", AUILiveCameraPushString(@"视频编码模式："), info.videoEncoderMode==0?@"Hardware":@"Soft"]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"音频输出码率："), info.audioUploadBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"视频输出码率："), info.videoUploadBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"缓存音频帧总数："), info.audioPacketsInUploadBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"缓存视频帧总数："), info.videoPacketsInUploadBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"视频上传帧率："), info.videoUploadFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"音频上传帧率："), info.audioUploadFps]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"当前上传音频帧PTS："), info.currentlyUploadedAudioFramePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"当前上传视频帧PTS："), info.currentlyUploadedVideoFramePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"上一个视频关键帧PTS："), info.previousVideoKeyframePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@: %lld\n", AUILiveCameraPushString(@"缓冲区中最后一帧视频："), info.lastVideoPtsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"缓冲区中最后一帧音频："), info.lastAudioPtsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", AUILiveCameraPushString(@"数据上传总大小："), info.totalSizeOfUploadedPackets]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"视频推流总耗时："), info.totalTimeOfUploading]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"当前视频流已发送总帧数："), info.totalFramesOfUploadedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"视频丢帧总数："), info.totalDurationOfDropingVideoFrames]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"视频丢帧次数："), info.totalTimesOfDropingVideoFrames]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"总的断网次数："), info.totalTimesOfDisconnect]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"总的重连次数："), info.totalTimesOfReconnect]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"视频延迟时长："), info.videoDurationFromCaptureToUpload]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"音频延迟时长："), info.audioDurationFromCaptureToUpload]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", AUILiveCameraPushString(@"当前上传帧大小："), info.currentUploadPacketSize]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"音视频pts差异："), info.audioVideoPtsDiff]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", AUILiveCameraPushString(@"缓冲队列中曾经最大的视频帧size："), info.maxSizeOfVideoPacketsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@%lld Bytes\n", AUILiveCameraPushString(@"缓冲队列中曾经最大的音频帧size："), info.maxSizeOfAudioPacketsInBuffer]];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.debugTextView.text = mutableString;
    });
}

@end
