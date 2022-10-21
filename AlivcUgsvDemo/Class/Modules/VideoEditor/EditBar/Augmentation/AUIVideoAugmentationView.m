//
//  AUIVideoAugmentationView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AUIVideoAugmentationView.h"
#import "AUIVideoEditorBaseEffectView.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

@interface AUIVideoAugmentationInfo ()<AUIVideoEditorBaseEffectInfo>
@property (nonatomic, readonly) float defaultValue;
@property (nonatomic, readonly) BOOL hasModify;
@end

@interface AUIVideoAugmentationView ()
@property (nonatomic, strong) AUIVideoEditorBaseEffectView *contentView;
@end


@implementation AUIVideoAugmentationView

// MARK: - Model
- (void)setInfos:(NSArray<AUIVideoAugmentationInfo *> *)infos {
    _infos = infos.copy;
    _contentView.infos = infos;
}

- (BOOL)selectWithType:(AliyunVideoAugmentationType)type {
    return [_contentView selectWithType:(NSInteger)type];
}

- (AUIVideoAugmentationInfo *)current {
    return (AUIVideoAugmentationInfo *)self.contentView.current;
}

// MARK: - UI
- (void)setup {
    // clear
    [_contentView removeFromSuperview];

    __weak typeof(self) weakSelf = self;
    // create
    _contentView = [AUIVideoEditorBaseEffectView new];
    _contentView.onSelectDidChanged = ^(id<AUIVideoEditorBaseEffectInfo> info) {
        if (weakSelf.onSelectedDidChanged) {
            weakSelf.onSelectedDidChanged((AUIVideoAugmentationInfo *)info);
        }
    };
    [self addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    // update
    self.backgroundColor = UIColor.clearColor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end


// MARK: - Model
typedef struct {
    AliyunVideoAugmentationType type;
    const char *title;
    const char *icon;
} __AugmentationUIInfo;

static const __AugmentationUIInfo * s_getAugmentationUIInfo(AliyunVideoAugmentationType type) {
    static const __AugmentationUIInfo s_augmentationInfos[] = {
        { AliyunVideoAugmentationTypeBrightness, "亮度", "ic_augmentation_brightness" },
        { AliyunVideoAugmentationTypeContrast, "对比度", "ic_augmentation_contrast" },
        { AliyunVideoAugmentationTypeSaturation, "饱和度", "ic_augmentation_saturation" },
        { AliyunVideoAugmentationTypeSharpness, "锐度", "ic_augmentation_sharpness" },
        { AliyunVideoAugmentationTypeVignette, "暗角", "ic_augmentation_vignette" },
    };
    
    const size_t AugmentationInfosSize = sizeof(s_augmentationInfos) / sizeof(s_augmentationInfos[0]);
    for (size_t i = 0; i < AugmentationInfosSize; ++i) {
        if (s_augmentationInfos[i].type == type) {
            return &(s_augmentationInfos[i]);
        }
    }
    return NULL;
}

@implementation AUIVideoAugmentationInfo
+ (AUIVideoAugmentationInfo *)InfoWithType:(AliyunVideoAugmentationType)type value:(float)value {
    AUIVideoAugmentationInfo *info = [AUIVideoAugmentationInfo new];
    info.type = type;
    info.value = value;
    return info;
}

+ (AUIVideoAugmentationInfo *)InfoWithType:(AliyunVideoAugmentationType)type {
    AUIVideoAugmentationInfo *info = [AUIVideoAugmentationInfo new];
    info.type = type;
    info.value = info.defaultValue;
    return info;
}

- (float)defaultValue {
    switch (_type) {
        case AliyunVideoAugmentationTypeBrightness:
            return AliyunVideoBrightnessDefaultValue;
        case AliyunVideoAugmentationTypeContrast:
            return AliyunVideoContrastDefaultValue;
        case AliyunVideoAugmentationTypeSaturation:
            return AliyunVideoSaturationDefaultValue;
        case AliyunVideoAugmentationTypeSharpness:
            return AliyunVideoSharpnessDefaultValue;
        case AliyunVideoAugmentationTypeVignette:
            return AliyunVideoVignetteDefaultValue;
        default:
            NSAssert(NO, @"Unknonw augmentation type");
            return 0.0;
    }
}

- (BOOL)isEqual:(id)object {
    AUIVideoAugmentationInfo *other = (AUIVideoAugmentationInfo *)object;
    if (![other isKindOfClass:AUIVideoAugmentationInfo.class]) {
        return NO;
    }
    return (other.type == self.type && fabs(other.value - self.value) < 0.00001);
}

// MARK: - AUIVideoEditorBaseEffectInfo
- (NSInteger)effectType {
    return (NSInteger)self.type;
}

- (NSString *)title {
    const __AugmentationUIInfo *info = s_getAugmentationUIInfo(_type);
    if (!info) {
        NSAssert(NO, @"Unkown augmentation type");
        return @"Unkown";
    }
    return AUIUgsvGetString(@(info->title));
}

- (UIImage *)icon {
    const __AugmentationUIInfo *info = s_getAugmentationUIInfo(_type);
    if (!info) {
        NSAssert(NO, @"Unkown augmentation type");
        return nil;
    }
    return AUIUgsvEditorImage(@(info->icon));
}

- (BOOL)flagModify {
    return fabs(self.defaultValue - self.value) > 0.001;
}
@end
