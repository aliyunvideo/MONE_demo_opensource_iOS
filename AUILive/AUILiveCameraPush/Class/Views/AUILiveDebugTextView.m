//
//  AUILiveDebugTextView.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/10/17.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AUILiveDebugTextView.h"

#import "AUILiveSDKHeader.h"

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

    [mutableString appendString:[NSString stringWithFormat:@"\n%@:\n\n", AUILiveCameraPushString(@"publisher_log")]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %.2f%%\n", AUILiveCameraPushString(@"text_log_1"), info.CPUHold]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %.2fMB\n\n", AUILiveCameraPushString(@"text_log_2"), info.memoryHold]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_3"), info.videoCaptureFps]];
    
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"text_log_5"), info.audioEncodedBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_6"), info.audioEncodedFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_42"), info.audioFramesInEncodeBuffer]];
    
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_7"), info.videoRenderFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_44"), info.videoFramesInRenderBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d ms\n", AUILiveCameraPushString(@"text_log_45"), info.videoRenderConsumingTimePerFrame]];

//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"text_log_9"), info.videoEncodedBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_43"), info.videoFramesInEncodeBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_10"), info.videoEncodedFps]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"text_log_11"), info.totalFramesOfEncodedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"text_log_12"), info.totalTimeOfEncodedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"text_log_13"), info.videoEncodeParam]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %@\n", AUILiveCameraPushString(@"text_log_8"), info.videoEncoderMode==0?@"Hardware":@"Soft"]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"text_log_14"), info.audioUploadBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", AUILiveCameraPushString(@"text_log_15"), info.videoUploadBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_16"), info.audioPacketsInUploadBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_17"), info.videoPacketsInUploadBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_18"), info.videoUploadFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_19"), info.audioUploadFps]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"text_log_21"), info.currentlyUploadedAudioFramePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"text_log_20"), info.currentlyUploadedVideoFramePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"text_log_22"), info.previousVideoKeyframePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@: %lld\n", AUILiveCameraPushString(@"text_log_23"), info.lastVideoPtsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"text_log_24"), info.lastAudioPtsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", AUILiveCameraPushString(@"text_log_25"), info.totalSizeOfUploadedPackets]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"text_log_26"), info.totalTimeOfUploading]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", AUILiveCameraPushString(@"text_log_27"), info.totalFramesOfUploadedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_28"), info.totalDurationOfDropingVideoFrames]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_29"), info.totalTimesOfDropingVideoFrames]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_30"), info.totalTimesOfDisconnect]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", AUILiveCameraPushString(@"text_log_31"), info.totalTimesOfReconnect]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"text_log_32"), info.videoDurationFromCaptureToUpload]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"text_log_33"), info.audioDurationFromCaptureToUpload]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", AUILiveCameraPushString(@"text_log_34"), info.currentUploadPacketSize]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", AUILiveCameraPushString(@"text_log_35"), info.audioVideoPtsDiff]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", AUILiveCameraPushString(@"text_log_37"), info.maxSizeOfVideoPacketsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@%lld Bytes\n", AUILiveCameraPushString(@"text_log_38"), info.maxSizeOfAudioPacketsInBuffer]];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.debugTextView.text = mutableString;
    });
}

@end
