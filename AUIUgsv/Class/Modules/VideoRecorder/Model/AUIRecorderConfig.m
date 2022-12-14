//
//  AUIRecorderConfig.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import "AUIRecorderConfig.h"
#import "AUIVideoParamBuilder.h"

@implementation AUIRecorderConfig

- (void) setVideoConfig:(AliyunRecorderVideoConfig *)videoConfig {
    if (!videoConfig) {
        videoConfig = [AliyunRecorderVideoConfig new];
    }
    _videoConfig = videoConfig;
    [self updateResolutionType];
}

const static struct {
    AUIRecorderHorizontalResolution type;
    CGFloat width;
} HorizontalResolutionInfos[] = {
    {AUIRecorderHorizontalResolution480, 480.0},
    {AUIRecorderHorizontalResolution540, 540.0},
    {AUIRecorderHorizontalResolution720, 720.0},
    {AUIRecorderHorizontalResolution1080, 1080.0},
};
const static size_t HorizontalResolutionInfosCount = sizeof(HorizontalResolutionInfos) / sizeof(HorizontalResolutionInfos[0]);

const static struct {
    AUIRecorderResolutionRatio type;
    CGFloat ratio;
} ResolutionRatioInfos[] = {
    {AUIRecorderResolutionRatio_1_1, 1.0},
    {AUIRecorderResolutionRatio_3_4, 3.0/4.0},
    {AUIRecorderResolutionRatio_9_16, 9.0/16.0},
};
const static size_t ResolutionRatioInfosCount = sizeof(ResolutionRatioInfos) / sizeof(ResolutionRatioInfos[0]);

- (void) updateResolutionType {
    CGSize size = _videoConfig.resolution;
    if (size.width <= 0 || size.height <= 0) {
        return;
    }
    
    for (int i = 0; i < HorizontalResolutionInfosCount; ++i) {
        if (HorizontalResolutionInfos[i].width == size.width) {
            _horizontalResolution = HorizontalResolutionInfos[i].type;
            break;
        }
    }
    
    CGFloat minDiff = CGFLOAT_MAX;
    CGFloat ratio = size.width / size.height;
    for (int i = 0; i < ResolutionRatioInfosCount; ++i) {
        CGFloat diff = fabs(ratio - ResolutionRatioInfos[i].ratio);
        if (diff < minDiff) {
            minDiff = diff;
            _resolutionRatio = ResolutionRatioInfos[i].type;
        }
    }
}

- (void) updateVideoResultion {
    CGSize size = CGSizeZero;
    for (int i = 0; i < HorizontalResolutionInfosCount; ++i) {
        if (_horizontalResolution == HorizontalResolutionInfos[i].type) {
            size.width = HorizontalResolutionInfos[i].width;
            break;
        }
    }
    
    for (int i = 0; i < ResolutionRatioInfosCount; ++i) {
        if (_resolutionRatio == ResolutionRatioInfos[i].type) {
            size.height = size.width / ResolutionRatioInfos[i].ratio;
            int validValue = size.height;
            validValue -= validValue & 1;
            size.height = validValue;
            break;
        }
    }

    _videoConfig.resolution = size;
}

- (void) setHorizontalResolution:(AUIRecorderHorizontalResolution)horizontalResolution {
    _horizontalResolution = horizontalResolution;
    [self updateVideoResultion];
}

- (void) setResolutionRatio:(AUIRecorderResolutionRatio)resolutionRatio {
    _resolutionRatio = resolutionRatio;
    [self updateVideoResultion];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoConfig = [AliyunRecorderVideoConfig new];
        _videoConfig.resolution = CGSizeMake(720, 1280);
        _videoConfig.encodeMode = AliyunRecorderEncodeMode_HardCoding;
        [self updateResolutionType];
        
        _isUsingAEC = NO;
        _isUsingCamera = YES;
        _minDuration = 3.0;
        _maxDuration = 15.0;
        _deleteVideoClipsOnExit = YES;
        _waterMarkPath = [NSBundle.mainBundle pathForResource:@"AlivcUgsv.bundle/logo_aliyun.png" ofType:@""];
#ifdef USING_SVIDEO_BASIC
        _mergeOnFinish = YES;
#endif // USING_SVIDEO_BASIC
    }
    return self;
}

- (BOOL)deleteVideoClipsOnExit {
    if (!_mergeOnFinish) {
        return NO;
    }
    return _deleteVideoClipsOnExit;
}

- (CGRect) cameraFrame {
    // TODO: ??????????????????????????????????????????????????????????????????
    CGRect frame = CGRectZero;
    frame.size = _videoConfig.resolution;
    return frame;
}

- (AUIUgsvParamBuilder *)paramBuilder {
    AUIUgsvParamBuilder *builder = [AUIUgsvParamBuilder new];
    builder
        .group(@"VideoOutput", @"????????????")
            .radioItem(@"ResolutionRatio", @"????????????")
                .option(@"9:16", @(AUIRecorderResolutionRatio_9_16))
                .option(@"3:4", @(AUIRecorderResolutionRatio_3_4))
                .option(@"1:1", @(AUIRecorderResolutionRatio_1_1))
                .KVC(self, @"resolutionRatio")
            .radioItem(@"HorizontalResolution", @"?????????")
                .option(@"480p", @(AUIRecorderHorizontalResolution480))
                .option(@"540p", @(AUIRecorderHorizontalResolution540))
                .option(@"720p", @(AUIRecorderHorizontalResolution720))
                .option(@"1080p", @(AUIRecorderHorizontalResolution1080))
                .KVC(self, @"horizontalResolution")
            .radioItem(@"ScaleModel", @"????????????")
                .option(@"??????", @(AliyunScaleModeFit))
                .option(@"??????", @(AliyunScaleModeFill))
                .KVC(self, @"videoConfig.scaleMode")
            .radioItem(@"EncodeMode", @"????????????")
                .option(@"?????????", @(AliyunRecorderEncodeMode_HardCoding))
                .option(@"?????????", @(AliyunRecorderEncodeMode_SoftCoding))
                .KVC(self, @"videoConfig.encodeMode")
            .radioItem(@"VideoQuality", @"????????????")
                .option(@"??????", @(AliyunVideoQualityVeryHight))
                .option(@"??????", @(AliyunVideoQualityHight))
                .option(@"??????", @(AliyunVideoQualityMedium))
                .option(@"??????", @(AliyunVideoQualityLow))
                .option(@"?????????", @(AliyunVideoQualityPoor))
                .option(@"?????????", @(AliyunVideoQualityExtraPoor))
                .KVC(self, @"videoConfig.videoQuality")
            .textFieldItem(@"Bitrate", @"??????").isInt()
                .placeHolder(@"?????????????????????????????????")
                .unit(@"kbps")
                .converter([AUIBitrateConverter new])
                .KVC(self, @"videoConfig.bitrate")
            .textFieldItem(@"FPS", @"??????").isInt()
                .KVC(self, @"videoConfig.fps")
            .textFieldItem(@"GOP", @"???????????????").isInt()
                .placeHolder(@"??????3?????????????????????????????????")
                .KVC(self, @"videoConfig.gop")
        .group(@"Duration", @"????????????")
            .textFieldItem(@"MinDuration", @"????????????").isInt()
                .placeHolder(@"??????>1s")
                .KVC(self, @"minDuration")
            .textFieldItem(@"MaxDuration", @"????????????").isInt()
                .KVC(self, @"maxDuration")
        .group(@"OnFinish", @"????????????")
            .switchItem(@"NeedMerge", @"??????Mp4")
                .KVC(self, @"mergeOnFinish");
    return builder;
}
@end
