//
//  AUIRecorderCountDownView.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import "AUIRecorderCountDownView.h"
#import "AVBaseButton.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

typedef void(^OnComplete)(BOOL isCanceled);
@interface AUIRecorderCountDownView ()
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) AVBaseButton *cancelBtn;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, copy) OnComplete onComplete;
@end

@implementation AUIRecorderCountDownView

+ (AUIRecorderCountDownView *) ShowInView:(UIView *)view complete:(OnComplete)complete {
    AUIRecorderCountDownView *countDown = [AUIRecorderCountDownView new];
    countDown.onComplete = complete;
    [view addSubview:countDown];
    [countDown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [countDown start];
    return countDown;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        _countLabel = [UILabel new];
        _countLabel.font = AVGetSemiboldFont(90);
        _countLabel.textColor = AUIFoundationColor(@"text_strong");
        [self addSubview:_countLabel];
        [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];

        __weak typeof(self) weakSelf = self;
        _cancelBtn = [AVBaseButton ImageButton];
        _cancelBtn.image = AUIUgsvRecorderImage(@"btn_close");
        [_cancelBtn setAction:^(AVBaseButton * _Nonnull btn) {
            [weakSelf finish:YES];
        }];
        [self addSubview:_cancelBtn];
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).inset(84.0);
        }];
    }
    return self;
}

- (void) finish:(BOOL)isCancel {
    if (_isFinished) {
        return;
    }
    _isFinished = YES;
    if (_onComplete) {
        _onComplete(isCancel);
    }
    [self removeFromSuperview];
}

- (void) start {
    _countLabel.alpha = 0.0;
    [self countTo:3];
}

- (void) countTo:(int)count {
    if (count == 0) {
        [self finish:NO];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _countLabel.text = @(count).stringValue;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.countLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (!weakSelf) {
            return;
        }
        [UIView animateWithDuration:0.1 delay:0.8 options:0 animations:^{
            weakSelf.countLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [weakSelf countTo:count-1];
        }];
    }];
}

@end
