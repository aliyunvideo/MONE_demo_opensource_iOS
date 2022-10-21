//
//  AUIRecorderBottomButtonsView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/2.
//

#import "AUIRecorderBottomButtonsView.h"
#import "AVBaseStateButton.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"
#import "AlivcUgsvSDKHeader.h"

@interface AUIRecorderBottomButtonsView ()
@property (nonatomic, strong) UIStackView *leftStackView;
@property (nonatomic, strong) UIView *rightStackView;
@property (nonatomic, strong) AVBaseButton *deleteBtn;
@property (nonatomic, strong) AVBaseButton *finishBtn;
@end

@implementation AUIRecorderBottomButtonsView

- (instancetype) initWithDelegate:(id<AUIRecorderBottomButtonsViewDelegate>)delegate {
    NSMutableArray *showTypes = @[].mutableCopy;
#ifdef INCLUDE_QUEEN
    [showTypes addObject:@(AUIRecorderBottomBtnTypeBeauty)];
#endif // INCLUDE_QUEEN
    
#ifndef USING_SVIDEO_BASIC
    [showTypes addObject:@(AUIRecorderBottomBtnTypeProps)];
#endif // USING_SVIDEO_BASIC
    
    return [self initWithShowTypes:showTypes delegate:delegate];
}

- (instancetype) initWithShowTypes:(NSArray<NSNumber *> *)showTypes
                          delegate:(id<AUIRecorderBottomButtonsViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _showTypes = showTypes.copy;
        _delegate = delegate;
        [self setupLeftStackView];
        [self setupRightStackView];
    }
    return self;
}

- (void) setPartCount:(NSUInteger)partCount {
    _partCount = partCount;
    [self updateRightStackUI];
}

- (void) setDuration:(NSTimeInterval)duration {
    _duration = duration;
    [self updateRightStackUI];
}

- (void) setMinDuration:(NSTimeInterval)minDuration {
    _minDuration = minDuration;
    [self updateRightStackUI];
}

// MARK: - Actions
- (void) onBtnDidPressed:(AUIRecorderBottomBtnType)btnType {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderBottomButtonsView:btnDidPressed:)]) {
        [_delegate onAUIRecorderBottomButtonsView:self btnDidPressed:btnType];
    }
}

- (void) onDeleteDidPressed {
    if ([_delegate respondsToSelector:@selector(onAUIRecorderBottomButtonsViewWantDelete:)]) {
        [_delegate onAUIRecorderBottomButtonsViewWantDelete:self];
    }
}

- (void) onFinishDidPressed {
    if (!self.enabledFinished) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(onAUIRecorderBottomButtonsViewWantFinish:)]) {
        [_delegate onAUIRecorderBottomButtonsViewWantFinish:self];
    }
}

// MARK: - UI
static const CGFloat CenterBlankSize = 60.0;
- (void) setupLeftStackView {
    // clear
    [_leftStackView removeFromSuperview];
    if (_showTypes.count == 0) {
        _leftStackView = nil;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44.0);
        }];
        return;
    }

    // create
    _leftStackView = [UIStackView new];
    _leftStackView.axis = UILayoutConstraintAxisHorizontal;
    _leftStackView.alignment = UIStackViewAlignmentCenter;
    _leftStackView.distribution = UIStackViewDistributionEqualSpacing;
    _leftStackView.layoutMarginsRelativeArrangement = YES;
    _leftStackView.layoutMargins = UIEdgeInsetsZero;
    [self addSubview:_leftStackView];
    [_leftStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self).multipliedBy(0.5).inset(CenterBlankSize*0.5);
    }];
    
    const NSDictionary<NSNumber *, AVBaseStateButtonInfo *> *StateInfos = @{
        @(AUIRecorderBottomBtnTypeBeauty): [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"美颜") image:AUIUgsvRecorderImage(@"ic_beautify")],
        @(AUIRecorderBottomBtnTypeProps): [AVBaseStateButtonInfo InfoWithTitle:AUIUgsvGetString(@"道具") image:AUIUgsvRecorderImage(@"ic_props")]
    };
    
    __weak typeof(self) weakSelf = self;
    for (NSNumber *type in _showTypes) {
        AVBaseButton *btn = [AVBaseButton ImageTextWithTitlePos:AVBaseButtonTitlePosBottom];
        btn.image = StateInfos[type].image;
        btn.title = StateInfos[type].title;
        [btn setAction:^(AVBaseButton *_) {
            [weakSelf onBtnDidPressed:(AUIRecorderBottomBtnType)type.intValue];
        }];
        [_leftStackView addArrangedSubview:btn];
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (_leftStackView) {
        [_leftStackView layoutIfNeeded];
        CGFloat space = (self.bounds.size.width - CenterBlankSize) * 0.5;
        for (UIView *btn in _leftStackView.arrangedSubviews) {
            space -= btn.av_width;
        }
        space /= (_leftStackView.arrangedSubviews.count + 1.0);
        _leftStackView.layoutMargins = UIEdgeInsetsMake(0, space, 0, space);
        [_leftStackView layoutIfNeeded];
    }
}

- (void) setupRightStackView {
    // clear
    [_rightStackView removeFromSuperview];

    // create
    _rightStackView = [UIView new];
    _rightStackView.backgroundColor = UIColor.clearColor;
    [self addSubview:_rightStackView];
    [_rightStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.centerX.equalTo(self).multipliedBy(1.5).offset(CenterBlankSize*0.25);
    }];
    
    __weak typeof(self) weakSelf = self;
    _deleteBtn = [AVBaseButton ImageTextWithTitlePos:AVBaseButtonTitlePosRight];
    _deleteBtn.spacing = 4.0;
    _deleteBtn.image = AUIUgsvRecorderImage(@"btn_delete");
    _deleteBtn.title = AUIUgsvGetString(@"回删");
    _deleteBtn.font = AVGetRegularFont(12.0);
    [_deleteBtn setAction:^(AVBaseButton *_) {
        [weakSelf onDeleteDidPressed];
    }];
    [_rightStackView addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(_rightStackView);
    }];

    _finishBtn = [AVBaseButton ImageButton];
    _finishBtn.image = AUIUgsvRecorderImage(@"btn_right");
    [_finishBtn setAction:^(AVBaseButton *btn) {
        [weakSelf onFinishDidPressed];
    }];
    [_rightStackView addSubview:_finishBtn];
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(_rightStackView);
        make.left.equalTo(_deleteBtn.mas_right).offset(17.0);
    }];

    [self updateRightStackUI];
}

- (BOOL)enabledFinished {
    return _duration >= _minDuration;
}

- (void) updateRightStackUI {
    BOOL hasRecord = (_partCount > 0);
    _deleteBtn.alpha = hasRecord ? 1.0 : 0.0;
    _finishBtn.alpha = hasRecord ? (self.enabledFinished ? 1.0 : 0.5) : 0.0;
}

@end
