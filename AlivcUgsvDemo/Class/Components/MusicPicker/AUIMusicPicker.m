//
//  AUIMusicPicker.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import "AUIMusicPicker.h"
#import "AUIMusicView.h"
#import "AUIUgsvMacro.h"
#import "AVBaseButton.h"
#import "Masonry.h"

@interface AUIMusicPicker()
@property (nonatomic, strong) AUIMusicView *musicView;
@property (nonatomic, strong) AVBaseButton *clearBtn;
@end

@implementation AUIMusicPicker

+ (AUIMusicPicker *)present:(UIView *)onView
              selectedModel:(AUIMusicSelectedModel * _Nullable)selectedModel
              limitDuration:(NSTimeInterval)limitDuration
           onSelectedChange:(OnMusicSelectedChanged _Nullable)onSelectedChanged
              onShowChanged:(OnMusicPickerShowChanged _Nullable)onShowChanged {
    CGRect frame = CGRectMake(0, 0, onView.av_width, self.panelHeight);
    AUIMusicPicker *picker = [[AUIMusicPicker alloc] initWithFrame:frame limitDuration:limitDuration];
    picker.currentSelected = selectedModel;
    picker.onSelectedChanged = onSelectedChanged;
    picker.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
        if (onShowChanged) {
            onShowChanged(sender.isShowing);
        }
    };
    [picker showOnView:onView];
    return picker;
}

+ (CGFloat)panelHeight {
    return 466.0 + AVSafeBottom;
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame limitDuration:15.0];
}

- (instancetype)initWithFrame:(CGRect)frame limitDuration:(NSTimeInterval)limitDuration {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithLimitDuration:limitDuration];
    }
    return self;
}

- (void)onMenuBtnClicked:(UIButton *)sender {
    if (self.onMenuClicked) {
        self.onMenuClicked(self);
    }
}

- (void) setupWithLimitDuration:(NSTimeInterval)limitDuration {
    // clear
    [_musicView removeFromSuperview];
    [_clearBtn removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    // create
    self.titleView.text = AUIUgsvGetString(@"音乐");
    _clearBtn = [AVBaseButton ImageButton];
    _clearBtn.image = AUIUgsvGetImage(@"ic_music_clear");
    _clearBtn.disabledImage = AUIUgsvGetImage(@"ic_music_clear_disabled");
    _clearBtn.disabled = YES;
    [_clearBtn setAction:^(AVBaseButton *btn) {
        if (btn.disabled) {
            return;
        }
        weakSelf.musicView.currentSelected = nil;
        btn.disabled = YES;
        if (weakSelf.onSelectedChanged) {
            weakSelf.onSelectedChanged(nil);
        }
    }];
    [self.headerView addSubview:_clearBtn];
    [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).inset(20.0);
        make.centerY.equalTo(self.headerView);
    }];
    
    _musicView = [[AUIMusicView alloc] initWithLimitDuration:limitDuration];
    _musicView.onSelectedChanged = ^(AUIMusicSelectedModel *model) {
        weakSelf.clearBtn.disabled = (model == nil);
        if (weakSelf.onSelectedChanged) {
            weakSelf.onSelectedChanged(model);
        }
    };
    [self.contentView addSubview:_musicView];
    [_musicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void) onShowChange:(BOOL)isShow {
    _musicView.isShowing = isShow;
    [super onShowChange:isShow];
}

// MARK: - passthrough
- (void) setPlayer:(id<AUIVideoPlayProtocol>)player {
    _musicView.player = player;
}
- (id<AUIVideoPlayProtocol>) player {
    return _musicView.player;
}

- (AUIMusicSelectedModel *) currentSelected {
    return _musicView.currentSelected;
}
- (void) setCurrentSelected:(AUIMusicSelectedModel * _Nullable)currentSelected {
    _musicView.currentSelected = currentSelected;
    _clearBtn.disabled = (_musicView.currentSelected == nil);
}

- (NSTimeInterval)limitDuration {
    return _musicView.limitDuration;
}

@end
