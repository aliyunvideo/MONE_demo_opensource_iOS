//
//  AUIVideoOutputParam.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/8.
//

#import "AUIVideoOutputParam.h"
#import "AUIVideoParamBuilder.h"


typedef struct _AUIOutputSizeTypeValue {
    AUIVideoOutputSizeType      type;
    CGSize                      size;
} AUIOutputSizeTypeValue;
const static AUIOutputSizeTypeValue TypeValueList[] = {
    {AUIVideoOutputSizeType480P, {480, 640}},
    {AUIVideoOutputSizeType540P, {540, 960}},
    {AUIVideoOutputSizeType720P, {720, 1280}},
    {AUIVideoOutputSizeType1080P, {1080, 1920}},
};
const static size_t TypeValueListCount = sizeof(TypeValueList) / sizeof(TypeValueList[0]);


typedef struct _AUIOutputSizeRatioValue {
    AUIVideoOutputSizeRatio      type;
    CGSize                      size;
} AUIOutputSizeRatioValue;
const static AUIOutputSizeRatioValue RatioValueList[] = {
    {AUIVideoOutputSizeRatio_9_16, {9, 16}},
    {AUIVideoOutputSizeRatio_3_4, {3, 4}},
    {AUIVideoOutputSizeRatio_1_1, {1, 1}},
    {AUIVideoOutputSizeRatio_16_9, {16, 9}},
    {AUIVideoOutputSizeRatio_4_3, {4, 3}}
};
const static size_t RatioValueListCount = sizeof(RatioValueList) / sizeof(RatioValueList[0]);


@interface AUIVideoOutputParam ()

@property(nonatomic, assign) CGSize outputSize;
@property(nonatomic, assign) AUIVideoOutputSizeRatio outputSizeRatio;
@property(nonatomic, assign) AUIVideoOutputSizeType outputSizeType;

@end

@implementation AUIVideoOutputParam

+ (instancetype)defaultVideoParam {
    return [self Portrait720P];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.outputSize = CGSizeMake(720, 1280);
        self.outputSizeRatio = AUIVideoOutputSizeRatio_9_16;
        self.outputSizeType = AUIVideoOutputSizeType720P;
        self.fps = 25;
        self.gop = self.fps * 3;
        self.scaleMode = AliyunScaleModeFill;
        self.videoQuality = AliyunVideoQualityHight;
        self.codecType = AliyunVideoCodecHardware;
    }
    return self;
}

- (instancetype)initWithOutputSize:(CGSize)outputSize {
    self = [self init];
    if (self) {
        [self updateOutSize:outputSize];
    }
    return self;
}

- (instancetype)initWithOutputSizeType:(AUIVideoOutputSizeType)type ratio:(AUIVideoOutputSizeRatio)ratio {
    self = [self init];
    if (self) {
        [self updateOutputSizeType:type ratio:ratio];
    }
    return self;
}

- (instancetype)initWithOutputSize:(CGSize)outputSize withAliyunVideoParam:(AliyunVideoParam *)videoParam {
    self = [self initWithOutputSize:outputSize];
    if (self) {
        if (videoParam) {
            self.fps = videoParam.fps;
            self.gop = videoParam.gop;
            self.bitrate = videoParam.bitrate;
            self.videoQuality = videoParam.videoQuality;
            self.scaleMode = videoParam.scaleMode;
            self.codecType = videoParam.codecType;
        }
    }
    return self;
}

- (void)updateOutSize:(CGSize)outputSize {
    outputSize = CGSizeMake([self evenValue:outputSize.width], [self evenValue:outputSize.height]);
    AUIVideoOutputSizeType type = AUIVideoOutputSizeTypeCustom;
    AUIVideoOutputSizeRatio ratio = AUIVideoOutputSizeRatio_original;
    if (CGSizeEqualToSize(outputSize, CGSizeZero)) {
        type = AUIVideoOutputSizeTypeOriginal;
    }
    else {
        
        for (int i = 0; i < TypeValueListCount; ++i) {
            CGSize size = TypeValueList[i].size;
            if (CGSizeEqualToSize(size, outputSize)) {
                type = TypeValueList[i].type;
                break;
            }
            size = CGSizeMake(size.height, size.width);
            if (CGSizeEqualToSize(size, outputSize)) {
                type = TypeValueList[i].type;
                break;
            }
        }
        
        if (type != AUIVideoOutputSizeTypeCustom && type != AUIVideoOutputSizeTypeOriginal) {
            CGFloat radioValue = outputSize.width / outputSize.height;
            for (int i = 0; i < RatioValueListCount; ++i) {
                CGSize size = RatioValueList[i].size;
                CGFloat defaultValue = size.width / size.height;
                CGFloat diff = fabs(defaultValue - radioValue);
                if (diff < 0.000001) {
                    ratio = RatioValueList[i].type;
                }
            }
        }
    }
    
    self.outputSize = outputSize;
    self.outputSizeType = type;
    self.outputSizeRatio = ratio;
}

- (void)updateOutputSizeType:(AUIVideoOutputSizeType)type ratio:(AUIVideoOutputSizeRatio)ratio {
    CGSize outputSize = CGSizeZero;
    if (type == AUIVideoOutputSizeTypeCustom || type == AUIVideoOutputSizeTypeOriginal || ratio == AUIVideoOutputSizeRatio_original) {
        type = AUIVideoOutputSizeTypeOriginal;
        ratio = AUIVideoOutputSizeRatio_original;
    }
    else {
        int width = 0;
        for (int i = 0; i < TypeValueListCount; ++i) {
            if (type == TypeValueList[i].type) {
                width = (int)(TypeValueList[i].size.width);
                break;
            }
        }
        
        int height = 0;
        for (int i = 0; i < RatioValueListCount; ++i) {
            if (ratio == RatioValueList[i].type) {
                CGSize ratio = RatioValueList[i].size;
                height = [self evenValue:width * ratio.height / ratio.width];
                break;
            }
        }
        outputSize = CGSizeMake(width, height);
    }
    
    self.outputSize = outputSize;
    self.outputSizeType = type;
    self.outputSizeRatio = ratio;
}

// 转换为偶数
- (int)evenValue:(CGFloat)input {
    int validValue = (int)input;
    validValue -= validValue & 1;
    return validValue;
}

+ (AUIVideoOutputParam *)original {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeTypeOriginal ratio:AUIVideoOutputSizeRatio_original];
}

+ (AUIVideoOutputParam *)Portrait480P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType480P ratio:AUIVideoOutputSizeRatio_3_4];
}

+ (AUIVideoOutputParam *)Landscape480P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType480P ratio:AUIVideoOutputSizeRatio_4_3];
}


+ (AUIVideoOutputParam *)Portrait540P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType540P ratio:AUIVideoOutputSizeRatio_9_16];
}

+ (AUIVideoOutputParam *)Landscape540P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType540P ratio:AUIVideoOutputSizeRatio_16_9];
}

+ (AUIVideoOutputParam *)Portrait720P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType720P ratio:AUIVideoOutputSizeRatio_9_16];
}

+ (AUIVideoOutputParam *)Landscape720P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType720P ratio:AUIVideoOutputSizeRatio_16_9];
}

+ (AUIVideoOutputParam *)Portrait1080P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType1080P ratio:AUIVideoOutputSizeRatio_9_16];
}

+ (AUIVideoOutputParam *)Landscape1080P {
    return [[AUIVideoOutputParam alloc] initWithOutputSizeType:AUIVideoOutputSizeType1080P ratio:AUIVideoOutputSizeRatio_16_9];
}

@end


@implementation AUIVideoOutputParam (ParamBuilder)

- (NSString *)outputSizeString {
    return [NSString stringWithFormat:@"%d * %d", (int)self.outputSize.width, (int)self.outputSize.height];
}

- (AUIUgsvParamBuilder *)paramBuilderWithoutAudioParam {
    return [self paramBuilderWithAudioParam:NO];
}

- (AUIUgsvParamBuilder *)paramBuilder {
    return [self paramBuilderWithAudioParam:YES];
}

- (AUIUgsvParamBuilder *)paramBuilderWithAudioParam:(BOOL)hasAudioParam {
    AUIUgsvParamBuilder *builder = [AUIUgsvParamBuilder new];
    AUIUgsvParamGroupBuilder *group = builder.group(@"VideoOutput", @"视频输出");
    
    if (self.outputSizeType == AUIVideoOutputSizeTypeCustom) {
        group = group
            .textFieldItem(@"Ratio", @"视频比例")
                .defaultValue(@"原始比例")
                .editabled(NO)
            .textFieldItem(@"Size", @"分辨率")
                .defaultValue([self outputSizeString])
                .editabled(NO)
        ;
    }
    else if (self.outputSizeType == AUIVideoOutputSizeTypeOriginal) {
        group = group
            .textFieldItem(@"Ratio", @"视频比例")
                .defaultValue(@"原始比例")
                .editabled(NO)
            .textFieldItem(@"Size", @"分辨率")
                .defaultValue(@"原始视频")
                .editabled(NO)
        ;
    }
    else {
        group = group
            .radioItem(@"Ratio", @"视频比例")
                .option(@"9:16", @(AUIVideoOutputSizeRatio_9_16))
                .option(@"3:4", @(AUIVideoOutputSizeRatio_3_4))
                .option(@"1:1", @(AUIVideoOutputSizeRatio_1_1))
                .option(@"16:9", @(AUIVideoOutputSizeRatio_16_9))
                .option(@"4:3", @(AUIVideoOutputSizeRatio_4_3))
                .defaultValue(@(self.outputSizeRatio))
                .onValueDidChange(^(id  _Nullable oldValue, id  _Nullable curValue) {
                    AUIVideoOutputSizeRatio ratio = [curValue unsignedIntValue];
                    [self updateOutputSizeType:self.outputSizeType ratio:ratio];
                })
            .radioItem(@"Size", @"分辨率")
                .option(@"480p", @(AUIVideoOutputSizeType480P))
                .option(@"540", @(AUIVideoOutputSizeType540P))
                .option(@"720p", @(AUIVideoOutputSizeType720P))
                .option(@"1080p", @(AUIVideoOutputSizeType1080P))
                .defaultValue(@(self.outputSizeType))
                .onValueDidChange(^(id  _Nullable oldValue, id  _Nullable curValue) {
                    AUIVideoOutputSizeType type = [curValue unsignedIntValue];
                    [self updateOutputSizeType:type ratio:self.outputSizeRatio];
                })
        ;
    }
    
    group = group
        .radioItem(@"ScaleModel", @"缩放模式")
            .option(@"裁剪", @(AliyunScaleModeFit))
            .option(@"填充", @(AliyunScaleModeFill))
            .KVC(self, @"scaleMode")
        .radioItem(@"CodecType", @"编码模式")
            .option(@"硬编码", @(AliyunVideoCodecHardware))
            .option(@"软编码", @(AliyunVideoCodecOpenh264))
            .KVC(self, @"codecType")
        .radioItem(@"VideoQuality", @"视频质量")
            .option(@"优质", @(AliyunVideoQualityVeryHight))
            .option(@"良好", @(AliyunVideoQualityHight))
            .option(@"一般", @(AliyunVideoQualityMedium))
            .option(@"较差", @(AliyunVideoQualityLow))
            .option(@"非常差", @(AliyunVideoQualityPoor))
            .option(@"极度差", @(AliyunVideoQualityExtraPoor))
            .KVC(self, @"videoQuality");
    if (hasAudioParam) {
        group = group
            .radioItem(@"AudioChannel", @"音频声道数")
                .option(@"单声道", @(AliyunAudioChannelTypeMono))
                .option(@"双声道", @(AliyunAudioChannelTypeStereo))
                .KVC(self, @"audioChannel")
            .radioItem(@"AudioSampleRate", @"音频采样率")
                .option(@"8K", @(AliyunAudioSampleRate8K))
                .option(@"12K", @(AliyunAudioSampleRate12K))
                .option(@"16K", @(AliyunAudioSampleRate16K))
                .option(@"24K", @(AliyunAudioSampleRate24K))
                .option(@"32K", @(AliyunAudioSampleRate32K))
                .option(@"44.1K", @(AliyunAudioSampleRate44_1K))
                .option(@"64K", @(AliyunAudioSampleRate64K))
                .option(@"88.2K", @(AliyunAudioSampleRate88_2K))
                .option(@"96K", @(AliyunAudioSampleRate96K))
                .KVC(self, @"audioSampleRate");
    }
    
    group.textFieldItem(@"Bitrate", @"码率")
            .isInt()
            .placeHolder(@"填入码率会忽略视频质量")
            .converter([AUIBitrateConverter new])
            .unit(@"kbps")
            .KVC(self, @"bitrate")
        .textFieldItem(@"FPS", @"帧率")
            .isInt()
            .placeHolder(@(self.fps).stringValue)
            .KVC(self, @"fps")
        .textFieldItem(@"GOP", @"关键帧间隔（建议3倍帧率）")
            .isInt()
            .placeHolder(@(self.gop).stringValue)
            .KVC(self, @"gop")
    ;
    return builder;
}

@end
