//
//  AUIAudioEffectView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import "AUIAudioEffectView.h"
#import "AUIVideoEditorBaseEffectView.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"

@interface AUIAudioEffectInfo : NSObject<AUIVideoEditorBaseEffectInfo>
@property (nonatomic, assign) AliyunAudioEffectType type;
+ (AUIAudioEffectInfo *) InfoWithType:(AliyunAudioEffectType)type;
@end

@interface AUIAudioEffectView ()
@property (nonatomic, strong) AUIVideoEditorBaseEffectView *contentView;
@end

@implementation AUIAudioEffectView

+ (NSArray<AUIAudioEffectInfo *> *) AudioEffectInfos {
    return @[
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectDefault],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectLolita],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectUncle],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectEcho],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectReverb],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectMinions],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectRobot],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectBigDevil],
        [AUIAudioEffectInfo InfoWithType:AliyunAudioEffectDialect],
    ];
}

- (void)setup {
    // clear
    [_contentView removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    // create
    _contentView = [AUIVideoEditorBaseEffectView new];
    _contentView.onSelectDidChanged = ^(id<AUIVideoEditorBaseEffectInfo> info) {
        if (weakSelf.onSelectedChanged) {
            weakSelf.onSelectedChanged((AliyunAudioEffectType)info.effectType);
        }
    };
    [self addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    // update
    self.backgroundColor = UIColor.clearColor;
    _contentView.infos = self.class.AudioEffectInfos;
}

- (void)setCurrent:(AliyunAudioEffectType)current {
    [_contentView selectWithType:(NSInteger)current];
}
- (AliyunAudioEffectType)current {
    return (AliyunAudioEffectType)_contentView.current.effectType;
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
    AliyunAudioEffectType type;
    const char *title;
    const char *icon;
} __AudioEffectUIInfo;

static const __AudioEffectUIInfo * s_getAudioEffectUIInfo(AliyunAudioEffectType type) {
    static const __AudioEffectUIInfo s_audioEffectUIInfo[] = {
        { AliyunAudioEffectDefault, "无", "ic_panel_reset" },
        { AliyunAudioEffectLolita, "萝莉", "ic_audioeffect_lolita" },
        { AliyunAudioEffectUncle, "大叔", "ic_audioeffect_uncle" },
        { AliyunAudioEffectEcho, "回音", "ic_audioeffect_ktv" },
        { AliyunAudioEffectReverb, "KTV", "ic_audioeffect_reverb" },
        { AliyunAudioEffectMinions, "小黄人", "ic_audioeffect_minions" },
        { AliyunAudioEffectRobot, "机器人", "ic_audioeffect_robot" },
        { AliyunAudioEffectBigDevil, "大魔王", "ic_audioeffect_bigdevil" },
        { AliyunAudioEffectDialect, "方言", "ic_audioeffect_dialect" },
    };
    const size_t AudioEffectUIInfoSize = sizeof(s_audioEffectUIInfo) / sizeof(s_audioEffectUIInfo[0]);
    for (size_t i = 0; i < AudioEffectUIInfoSize; ++i) {
        if (s_audioEffectUIInfo[i].type == type) {
            return &(s_audioEffectUIInfo[i]);
        }
    }
    return NULL;
}

@implementation AUIAudioEffectInfo

+ (AUIAudioEffectInfo *) InfoWithType:(AliyunAudioEffectType)type {
    AUIAudioEffectInfo *info = [AUIAudioEffectInfo new];
    info.type = type;
    return info;
}

// MARK: - AUIVideoEditorBaseEffectInfo
- (NSInteger) effectType {
    return (NSInteger)self.type;
}

- (NSString *)title {
    const __AudioEffectUIInfo *info = s_getAudioEffectUIInfo(_type);
    if (!info) {
        NSAssert(NO, @"Unkown audio effect type");
        return @"Unkown";
    }
    return AUIUgsvGetString(@(info->title));
}

- (UIImage *)icon {
    const __AudioEffectUIInfo *info = s_getAudioEffectUIInfo(_type);
    if (!info) {
        NSAssert(NO, @"Unkown audio effect type");
        return nil;
    }
    return AUIUgsvEditorImage(@(info->icon));
}

@end
