//
//  AUILivePullPlayActionView.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/6/14.
//

#import "AUILivePullPlayActionView.h"
#import "AVBaseButton.h"
#import <Masonry/Masonry.h>

#define kPullBtn_height (44 + 14)

@interface AUILivePullPlayActionView ()

@property (nonatomic, strong) AVBaseButton *stopPlayBtn;
@property (nonatomic, strong) AVBaseButton *mutedBtn;
@property (nonatomic, strong) AVBaseButton *dataIndicatorBtn;

@end

@implementation AUILivePullPlayActionView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.stopPlayBtn];
        [self addSubview:self.mutedBtn];
        [self addSubview:self.dataIndicatorBtn];
        [self.stopPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.mas_equalTo(self.mutedBtn.mas_left).mas_offset(-47);
            make.size.mas_equalTo(CGSizeMake(55, kPullBtn_height));
        }];
        [self.mutedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(55, kPullBtn_height));
        }];
        [self.dataIndicatorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.mas_equalTo(self.mutedBtn.mas_right).mas_offset(47);
            make.size.mas_equalTo(CGSizeMake(55, kPullBtn_height));
        }];
    }
    return self;
}

- (AVBaseButton *)stopPlayBtn {
    if (!_stopPlayBtn) {
        _stopPlayBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        _stopPlayBtn.image = AUILivePlayImage(@"pull_stopplay");
        _stopPlayBtn.title = AUILivePlayString(@"结束观看");
        
        __weak typeof(self) weakSelf = self;
        _stopPlayBtn.action = ^(AVBaseButton * _Nonnull btn) {
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf.stopPlayAction) {
                strongSelf.stopPlayAction();
            }
        };
    }
    return _stopPlayBtn;
}

- (AVBaseButton *)mutedBtn {
    if (!_mutedBtn) {
        _mutedBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        _mutedBtn.image = AUILivePlayImage(@"pull_muted");
        _mutedBtn.title = AUILivePlayString(@"静音");
        
        __weak typeof(self) weakSelf = self;
        _mutedBtn.action = ^(AVBaseButton * _Nonnull btn) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.muted = !strongSelf.muted;
            [strongSelf updateMutedButton];
            if (strongSelf.mutedAction) {
                strongSelf.mutedAction(strongSelf.muted);
            }
        };
    }
    return _mutedBtn;
}

- (AVBaseButton *)dataIndicatorBtn {
    if (!_dataIndicatorBtn) {
        _dataIndicatorBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        _dataIndicatorBtn.image = AUILivePlayImage(@"pull_dataindicator");
        _dataIndicatorBtn.title = AUILivePlayString(@"数据指标");
        
        __weak typeof(self) weakSelf = self;
        _dataIndicatorBtn.action = ^(AVBaseButton * _Nonnull btn) {
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf.dataIndicatorAction) {
                strongSelf.dataIndicatorAction();
            }
        };
    }
    return _dataIndicatorBtn;
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    [self updateMutedButton];
}

- (void)updateMutedButton {
    if (self.muted) {
        self.mutedBtn.image = AUILivePlayImage(@"pull_volume");
        self.mutedBtn.title = AUILivePlayString(@"取消静音");
    } else {
        self.mutedBtn.image = AUILivePlayImage(@"pull_muted");
        self.mutedBtn.title = AUILivePlayString(@"静音");
    }
}

@end
