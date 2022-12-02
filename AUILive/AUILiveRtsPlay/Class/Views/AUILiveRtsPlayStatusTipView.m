//
//  AUILiveRtsPlayStatusTipView.m
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/11/17.
//

#import "AUILiveRtsPlayStatusTipView.h"

@interface AUILiveRtsPlayStatusTipView ()

@property (nonatomic, strong) UILabel *errMsgLabel;
@property (nonatomic, strong) UILabel *downgradeMsgLabel;

@end

@implementation AUILiveRtsPlayStatusTipView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.errMsgLabel];
        self.errMsgLabel.hidden = YES;
        
        [self addSubview:self.downgradeMsgLabel];
        self.downgradeMsgLabel.hidden = YES;
    }
    return self;
}

- (void)setErrMsg:(NSString *)errMsg {
    _errMsg = errMsg;
    self.errMsgLabel.text = errMsg;
}

- (void)setDowngradeMsg:(NSString *)downgradeMsg {
    _downgradeMsg = downgradeMsg;
    self.downgradeMsgLabel.text = downgradeMsg;
}

- (void)showErrMsg:(BOOL)isShowErrMsg downgradeMsg:(BOOL)isShowDowngradeMsg {
    self.errMsgLabel.hidden = !isShowErrMsg;
    self.downgradeMsgLabel.hidden = !isShowDowngradeMsg;
    if (isShowErrMsg) {
        if (isShowDowngradeMsg) {
            self.errMsgLabel.av_top = self.av_height / 2.0 - 10 / 2.0 - 22;
            self.downgradeMsgLabel.av_top = self.av_height / 2.0 + 10 / 2.0;
        } else {
            self.errMsgLabel.av_top = (self.av_height - 22) / 2.0;
        }
    } else {
        self.hidden = YES;
    }
}

#pragma mark -- lazy load
- (UILabel *)errMsgLabel {
    if (!_errMsgLabel) {
        _errMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.av_height / 2.0 - 10 / 2.0 - 22, self.av_width, 22)];
        _errMsgLabel.textColor = AUILiveRtsPlayColor(@"rp_err_msg");
        _errMsgLabel.textAlignment = NSTextAlignmentCenter;
        _errMsgLabel.font = AVGetMediumFont(14);
        _errMsgLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _errMsgLabel;
}

- (UILabel *)downgradeMsgLabel {
    if (!_downgradeMsgLabel) {
        _downgradeMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.av_height / 2.0 + 10 / 2.0, self.av_width, 22)];
        _downgradeMsgLabel.textColor = AUILiveRtsPlayColor(@"rp_jiangji_msg");
        _downgradeMsgLabel.textAlignment = NSTextAlignmentCenter;
        _downgradeMsgLabel.font = AVGetMediumFont(14);
        _downgradeMsgLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _downgradeMsgLabel;
}

@end
