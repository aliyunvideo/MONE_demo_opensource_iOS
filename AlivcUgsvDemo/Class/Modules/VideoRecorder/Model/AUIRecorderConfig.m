//
//  AUIRecorderConfig.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import "AUIRecorderConfig.h"
#import "AUIVideoParamBuilder.h"
#import "AUIUgsvMacro.h"

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
    [self updateFrame];
}

- (void)updateFrame {
    CGSize size = _videoConfig.resolution;
    if (self.isMixRecord) {
        CGRect first = CGRectZero;
        CGRect second = CGRectZero;
        if (_mixType == AUIRecorderMixTypeBackFront || _mixType == AUIRecorderMixTypeFrontBack) {
            first.size = size;
            first.origin = CGPointMake(0, 0);
            CGFloat ratio = _videoConfig.resolution.width / _videoConfig.resolution.height;
            second.size = CGSizeMake(size.width / 3.0, size.width / 3.0 / ratio);
            second.origin = CGPointMake(0, 0);
        }
        else if (_mixType == AUIRecorderMixTypeTopBottom || _mixType == AUIRecorderMixTypeBottomTop) {
            first.size = CGSizeMake(size.width, size.height / 2.0);
            first.origin = CGPointMake(0, 0);
            second.size = CGSizeMake(size.width, size.height / 2.0);
            second.origin = CGPointMake(0, size.height / 2.0);
        }
        else {
            first.size = CGSizeMake(size.width / 2.0, size.height);
            first.origin = CGPointMake(0, 0);
            second.size = CGSizeMake(size.width / 2.0, size.height);
            second.origin = CGPointMake(size.width / 2.0, 0);
        }
        if (_mixType % 2 == 0) {
            _cameraFrame = second;
            _mixVideoFrame = first;
            _cameraZPosition = 2;
            _mixVideoZPosition = 1;
        }
        else {
            _cameraFrame = first;
            _mixVideoFrame = second;
            _cameraZPosition = 1;
            _mixVideoZPosition = 2;
        }
    }
    else {
        _cameraFrame = CGRectMake(0, 0, size.width, size.height);
        _mixVideoFrame = CGRectZero;
        _cameraZPosition = 2;
        _mixVideoZPosition = 1;
    }
}

- (void) setHorizontalResolution:(AUIRecorderHorizontalResolution)horizontalResolution {
    _horizontalResolution = horizontalResolution;
    [self updateVideoResultion];
}

- (void) setResolutionRatio:(AUIRecorderResolutionRatio)resolutionRatio {
    _resolutionRatio = resolutionRatio;
    [self updateVideoResultion];
}

- (BOOL)isMixRecord {
    BOOL isMix = _mixVideoFilePath.length > 0;
    return isMix;
}

- (void)setMixVideoFilePath:(NSString *)mixVideoFilePath {
    _mixVideoFilePath = mixVideoFilePath;
    [self updateFrame];
}

- (void)setMixType:(AUIRecorderMixType)mixType {
    _mixType = mixType;
    [self updateFrame];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoConfig = [AliyunRecorderVideoConfig new];
        _videoConfig.resolution = CGSizeMake(720, 1280);
        _videoConfig.encodeMode = AliyunRecorderEncodeMode_HardCoding;
        [self updateResolutionType];
        [self updateFrame];
        
        _isUsingAEC = NO;
        _minDuration = 3.0;
        _maxDuration = 15.0;
        _mergeOnFinish = NO;
        _deleteVideoClipsOnExit = YES;
        _waterMarkPath = [NSBundle.mainBundle pathForResource:@"AlivcUgsv.bundle/logo_aliyun.png" ofType:@""];
    }
    return self;
}

- (BOOL)deleteVideoClipsOnExit {
    if (!_mergeOnFinish) {
        return NO;
    }
    return _deleteVideoClipsOnExit;
}

- (AUIUgsvParamBuilder *)paramBuilder {
    AUIUgsvParamBuilder *builder = [AUIUgsvParamBuilder new];
    builder
        .group(@"VideoOutput", AUIUgsvGetString(@"视频输出"))
            .radioItem(@"ResolutionRatio", AUIUgsvGetString(@"视频比例"))
                .option(@"9:16", @(AUIRecorderResolutionRatio_9_16))
                .option(@"3:4", @(AUIRecorderResolutionRatio_3_4))
                .option(@"1:1", @(AUIRecorderResolutionRatio_1_1))
                .KVC(self, @"resolutionRatio")
            .radioItem(@"HorizontalResolution", AUIUgsvGetString(@"分辨率"))
                .option(@"480p", @(AUIRecorderHorizontalResolution480))
                .option(@"540p", @(AUIRecorderHorizontalResolution540))
                .option(@"720p", @(AUIRecorderHorizontalResolution720))
                .option(@"1080p", @(AUIRecorderHorizontalResolution1080))
                .KVC(self, @"horizontalResolution")
            .radioItem(@"ScaleModel", AUIUgsvGetString(@"缩放模式"))
                .option(AUIUgsvGetString(@"裁剪模式"), @(AliyunScaleModeFit))
                .option(AUIUgsvGetString(@"填充模式"), @(AliyunScaleModeFill))
                .KVC(self, @"videoConfig.scaleMode")
            .radioItem(@"EncodeMode", AUIUgsvGetString(@"编码模式"))
                .option(AUIUgsvGetString(@"硬编码"), @(AliyunRecorderEncodeMode_HardCoding))
                .option(AUIUgsvGetString(@"软编码"), @(AliyunRecorderEncodeMode_SoftCoding))
                .KVC(self, @"videoConfig.encodeMode")
            .radioItem(@"VideoQuality", AUIUgsvGetString(@"视频质量"))
                .option(AUIUgsvGetString(@"优质"), @(AliyunVideoQualityVeryHight))
                .option(AUIUgsvGetString(@"良好"), @(AliyunVideoQualityHight))
                .option(AUIUgsvGetString(@"一般"), @(AliyunVideoQualityMedium))
                .option(AUIUgsvGetString(@"较差"), @(AliyunVideoQualityLow))
                .option(AUIUgsvGetString(@"非常差"), @(AliyunVideoQualityPoor))
                .option(AUIUgsvGetString(@"极度差"), @(AliyunVideoQualityExtraPoor))
                .KVC(self, @"videoConfig.videoQuality")
            .textFieldItem(@"Bitrate", AUIUgsvGetString(@"码率")).isInt()
                .placeHolder(AUIUgsvGetString(@"填入码率会忽略视频质量"))
                .unit(@"kbps")
                .converter([AUIBitrateConverter new])
                .KVC(self, @"videoConfig.bitrate")
            .textFieldItem(@"FPS", AUIUgsvGetString(@"帧率")).isInt()
                .KVC(self, @"videoConfig.fps")
            .textFieldItem(@"GOP", AUIUgsvGetString(@"关键帧间隔")).isInt()
                .placeHolder(AUIUgsvGetString(@"建议3秒（配合帧率计算设置）"))
                .KVC(self, @"videoConfig.gop")
        .group(@"Duration", AUIUgsvGetString(@"录制时间"))
            .textFieldItem(@"MinDuration", AUIUgsvGetString(@"最小时长")).isInt()
                .placeHolder(AUIUgsvGetString(@"建议>1s"))
                .KVC(self, @"minDuration")
            .textFieldItem(@"MaxDuration", AUIUgsvGetString(@"最大时长")).isInt()
                .KVC(self, @"maxDuration")
        .group(@"OnFinish", AUIUgsvGetString(@"结束设置"))
            .switchItem(@"NeedMerge", AUIUgsvGetString(@"输出Mp4"))
                .KVC(self, @"mergeOnFinish");
    return builder;
}

- (AUIUgsvParamBuilder *)mixRecordParamBuilder {
    AUIUgsvParamBuilder *builder = [self paramBuilder];
    builder.group(@"Mix", AUIUgsvGetString(@"合拍参数"))
        .radioItem(@"mixType", AUIUgsvGetString(@"布局"))
            .option(AUIUgsvGetString(@"左右"), @(AUIRecorderMixTypeLeftRight))
            .option(AUIUgsvGetString(@"右左"), @(AUIRecorderMixTypeRightLeft))
            .option(AUIUgsvGetString(@"上下"), @(AUIRecorderMixTypeTopBottom))
            .option(AUIUgsvGetString(@"下上"), @(AUIRecorderMixTypeBottomTop))
            .option(AUIUgsvGetString(@"后前"), @(AUIRecorderMixTypeBackFront))
            .option(AUIUgsvGetString(@"前后"), @(AUIRecorderMixTypeFrontBack))
            .KVC(self, @"mixType")
        .switchItem(@"isUsingAEC", AUIUgsvGetString(@"开启回声消除"))
            .KVC(self, @"isUsingAEC");
    return builder;
}

@end
