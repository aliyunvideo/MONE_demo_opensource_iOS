//
//  AUILiveDebugChartView.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 2017/10/9.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILiveDebugChartView.h"
#import "AUILiveChartView.h"

#define kAUILiveChartViewRetractX AlivcSizeWidth(20)
#define kAUILiveChartViewRetractY (AlivcSizeWidth(5) + kAUILiveChartViewRetractX)
#define kAlivcChartModuleHeight AlivcSizeWidth(150)
#define kAUILiveChartViewModuleCount 4

@interface AUILiveDebugChartView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) AUILiveChartView *videoRenderBuffer;
@property (nonatomic, strong) AUILiveChartView *audioEncodeBuffer;
@property (nonatomic, strong) AUILiveChartView *videoEncodeBuffer;
@property (nonatomic, strong) AUILiveChartView *videoUploadBuffer;
@property (nonatomic, strong) AUILiveChartView *audioUploadBuffer;

@property (nonatomic, strong) AUILiveChartView *captureAudioFPS;
@property (nonatomic, strong) AUILiveChartView *zoomAudioFPS;
@property (nonatomic, strong) AUILiveChartView *encodeAudioFPS;
@property (nonatomic, strong) AUILiveChartView *pushAudioFPS;

@property (nonatomic, strong) AUILiveChartView *captureVideoFPS;
@property (nonatomic, strong) AUILiveChartView *zoomVideoFPS;
@property (nonatomic, strong) AUILiveChartView *encodeVideoFPS;
@property (nonatomic, strong) AUILiveChartView *pushVideoFPS;

@property (nonatomic, strong) AUILiveChartView *encodeVideoBitrate;
@property (nonatomic, strong) AUILiveChartView *encodeAudioBitrate;
@property (nonatomic, strong) AUILiveChartView *pushBiterate;

@end

@implementation AUILiveDebugChartView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


- (void)setupSubViews {
    
    [self setupScrollView];
    [self setupDurationViewsWithIndex:0];
    [self setupAudioFPSViewsWithIndex:1];
    [self setupVideoFPSViewsWithIndex:2];
    [self setupBitrateViewsWithIndex:3];
}


- (void)setupScrollView {
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.contentSize = CGSizeMake(0, kAlivcChartModuleHeight*kAUILiveChartViewModuleCount);
    self.scrollView.frame = self.bounds;
    [self addSubview:self.scrollView];
}


- (void)setupDurationViewsWithIndex:(int)index {
    
    
    CGFloat totalProgress = 50;
    
    UIView *durationView = [[UIView alloc] init];
    durationView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:durationView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAUILiveChartViewRetractX, kAUILiveChartViewRetractX, 200, kAUILiveChartViewRetractX);
    titleLabel.text = AUILiveCameraPushString(@"buffer");
    [durationView addSubview:titleLabel];
    
    self.videoRenderBuffer = [[AUILiveChartView alloc]
                            initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                      kAUILiveChartViewRetractY * 2,
                                                      CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                      kAUILiveChartViewRetractX))
                            
                            backgroundColor:[UIColor clearColor]
                            barColor:[UIColor redColor]
                            barTitle:AUILiveCameraPushString(@"video_renderbuffer")
                            barTotalProgress:totalProgress];
    [durationView addSubview:self.videoRenderBuffer];
    
    self.videoEncodeBuffer = [[AUILiveChartView alloc]
                         initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                   kAUILiveChartViewRetractY * 3,
                                                   CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                   kAUILiveChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor blueColor]
                         barTitle:AUILiveCameraPushString(@"video_encodebuffer")
                         barTotalProgress:totalProgress];
    [durationView addSubview:self.videoEncodeBuffer];
    
    
    self.audioEncodeBuffer = [[AUILiveChartView alloc]
                           initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                     kAUILiveChartViewRetractY * 4,
                                                     CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                     kAUILiveChartViewRetractX))
                           backgroundColor:[UIColor clearColor]
                           barColor:[UIColor blackColor]
                           barTitle:AUILiveCameraPushString(@"audio_encodebuffer")
                           barTotalProgress:totalProgress];
    [durationView addSubview:self.audioEncodeBuffer];
    
    
    self.videoUploadBuffer = [[AUILiveChartView alloc]
                         initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                   kAUILiveChartViewRetractY * 5,
                                                   CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                   kAUILiveChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:AUILiveCameraPushString(@"video_uploadbuffer")
                         barTotalProgress:totalProgress];
    [durationView addSubview:self.videoUploadBuffer];
    
    self.audioUploadBuffer = [[AUILiveChartView alloc]
                          initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                    kAUILiveChartViewRetractY * 6,
                                                    CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                    kAUILiveChartViewRetractX))
                          backgroundColor:[UIColor clearColor]
                          barColor:[UIColor orangeColor]
                          barTitle:AUILiveCameraPushString(@"audio_uploadbuffer")
                          barTotalProgress:totalProgress];
    [durationView addSubview:self.audioUploadBuffer];
    
}


- (void)setupAudioFPSViewsWithIndex:(int)index {
    
    CGFloat totalProgress = 50;
    
    UIView *audioFPSView = [[UIView alloc] init];
    audioFPSView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:audioFPSView];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAUILiveChartViewRetractX, kAUILiveChartViewRetractX, 200, kAUILiveChartViewRetractX);
    titleLabel.text = AUILiveCameraPushString(@"modules_audio_fps");
    [audioFPSView addSubview:titleLabel];
    
    self.captureAudioFPS = [[AUILiveChartView alloc]
                            initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                      kAUILiveChartViewRetractY * 2,
                                                      CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                      kAUILiveChartViewRetractX))
                            backgroundColor:[UIColor clearColor]
                            barColor:[UIColor redColor]
                            barTitle:AUILiveCameraPushString(@"capture")
                            barTotalProgress:totalProgress];
//    [audioFPSView addSubview:self.captureAudioFPS];
    
    
    self.encodeAudioFPS = [[AUILiveChartView alloc]
                           initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                     kAUILiveChartViewRetractY * 3,
                                                     CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                     kAUILiveChartViewRetractX))
                           backgroundColor:[UIColor clearColor]
                           barColor:[UIColor blackColor]
                           barTitle:AUILiveCameraPushString(@"encode")
                           barTotalProgress:totalProgress];
    [audioFPSView addSubview:self.encodeAudioFPS];
    
    
    self.pushAudioFPS = [[AUILiveChartView alloc]
                         initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                   kAUILiveChartViewRetractY * 4,
                                                   CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                   kAUILiveChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:AUILiveCameraPushString(@"push")
                         barTotalProgress:totalProgress];
    [audioFPSView addSubview:self.pushAudioFPS];
    
}


- (void)setupVideoFPSViewsWithIndex:(int)index {
    
    CGFloat totalProgress = 50;
    
    UIView *videoFPSView = [[UIView alloc] init];
    videoFPSView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:videoFPSView];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAUILiveChartViewRetractX, kAUILiveChartViewRetractX, 200, kAUILiveChartViewRetractX);
    titleLabel.text = AUILiveCameraPushString(@"modules_video_fps");
    [videoFPSView addSubview:titleLabel];
    
    self.captureVideoFPS = [[AUILiveChartView alloc]
                            initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                      kAUILiveChartViewRetractY * 2,
                                                      CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                      kAUILiveChartViewRetractX))
                            backgroundColor:[UIColor clearColor]
                            barColor:[UIColor redColor]
                            barTitle:AUILiveCameraPushString(@"capture")
                            barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.captureVideoFPS];
    
    self.zoomVideoFPS = [[AUILiveChartView alloc]
                         initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                   kAUILiveChartViewRetractY * 3,
                                                   CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                   kAUILiveChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor blueColor]
                         barTitle:AUILiveCameraPushString(@"render")
                         barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.zoomVideoFPS];
    
    
    self.encodeVideoFPS = [[AUILiveChartView alloc]
                           initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                     kAUILiveChartViewRetractY * 4,
                                                     CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                     kAUILiveChartViewRetractX))
                           backgroundColor:[UIColor clearColor]
                           barColor:[UIColor blackColor]
                           barTitle:AUILiveCameraPushString(@"encode")
                           barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.encodeVideoFPS];
    
    
    self.pushVideoFPS = [[AUILiveChartView alloc]
                         initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                   kAUILiveChartViewRetractY * 5,
                                                   CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                   kAUILiveChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:AUILiveCameraPushString(@"push")
                         barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.pushVideoFPS];
    
}


- (void)setupBitrateViewsWithIndex:(int)index {
    
    CGFloat totalProgress = 5000;
    
    UIView *bitrateView = [[UIView alloc] init];
    bitrateView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:bitrateView];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAUILiveChartViewRetractX, kAUILiveChartViewRetractX, 200, kAUILiveChartViewRetractX);
    titleLabel.text = AUILiveCameraPushString(@"modules_bitrate");
    [bitrateView addSubview:titleLabel];
    
    self.encodeVideoBitrate = [[AUILiveChartView alloc]
                          initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                    kAUILiveChartViewRetractY * 2,
                                                    CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                    kAUILiveChartViewRetractX))
                          backgroundColor:[UIColor clearColor]
                          barColor:[UIColor blackColor]
                          barTitle:AUILiveCameraPushString(@"video_encode")
                          barTotalProgress:totalProgress];
    [bitrateView addSubview:self.encodeVideoBitrate];
    
    self.encodeAudioBitrate = [[AUILiveChartView alloc]
                         initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                   kAUILiveChartViewRetractY * 3,
                                                   CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                   kAUILiveChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor blackColor]
                         barTitle:AUILiveCameraPushString(@"audio_encode")
                         barTotalProgress:totalProgress];
    [bitrateView addSubview:self.encodeAudioBitrate];
    
    self.pushBiterate = [[AUILiveChartView alloc]
                         initWithFrame:(CGRectMake(kAUILiveChartViewRetractX * 2,
                                                   kAUILiveChartViewRetractY * 4,
                                                   CGRectGetWidth(self.frame) - kAUILiveChartViewRetractX * 4,
                                                   kAUILiveChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:AUILiveCameraPushString(@"push")
                         barTotalProgress:totalProgress];
    [bitrateView addSubview:self.pushBiterate];
    
}


- (void)updateData:(AlivcLivePushStatsInfo *)info {
    
    
    [self.videoRenderBuffer updateBarProgress:info.videoFramesInRenderBuffer];
    [self.videoEncodeBuffer updateBarProgress:info.videoFramesInEncodeBuffer];
    [self.audioEncodeBuffer updateBarProgress:info.audioFramesInEncodeBuffer];
    [self.videoUploadBuffer updateBarProgress:info.videoPacketsInUploadBuffer];
    [self.audioUploadBuffer updateBarProgress:info.audioPacketsInUploadBuffer];

    [self.encodeAudioFPS updateBarProgress:info.audioEncodedFps];
    [self.pushAudioFPS updateBarProgress:info.audioUploadFps];
    
    [self.captureVideoFPS updateBarProgress:info.videoCaptureFps];
    [self.zoomVideoFPS updateBarProgress:info.videoRenderFps];
    [self.encodeVideoFPS updateBarProgress:info.videoEncodedFps];
    [self.pushVideoFPS updateBarProgress:info.videoUploadFps];
    
    [self.encodeVideoBitrate updateBarProgress:info.videoEncodedBitrate];
    [self.encodeAudioBitrate updateBarProgress:info.audioEncodedBitrate];
    [self.pushBiterate updateBarProgress:info.videoUploadBitrate];
}

@end
