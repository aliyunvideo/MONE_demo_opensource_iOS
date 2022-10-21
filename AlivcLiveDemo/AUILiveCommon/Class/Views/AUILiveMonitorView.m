//
//  AUILiveMonitorView.m
//  AliLiveSdk-Demo
//
//  Created by lichentao on 2020/12/23.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "AUILiveMonitorView.h"
@implementation AUILiveMonitorView


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.sentBitrateLabel];
        [self addSubview:self.sentFpsLabel];
        [self addSubview:self.encodeFpsLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(12, 10, 130, 20);
    _sentBitrateLabel.frame = CGRectMake(12, 40, 230, 20);
    _sentFpsLabel.frame = CGRectMake(12, 65, 130, 20);
    _encodeFpsLabel.frame = CGRectMake(12, 90, 130, 20);
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = AUILiveCommonColor(@"ir_monitor_title");
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}
- (UILabel *)sentBitrateLabel{
    if (!_sentBitrateLabel) {
        _sentBitrateLabel = [[UILabel alloc] init];
        _sentBitrateLabel.textColor = [UIColor whiteColor];
        _sentBitrateLabel.font = [UIFont systemFontOfSize:12];
    }
    return _sentBitrateLabel;
}
- (UILabel *)sentFpsLabel{
    if (!_sentFpsLabel) {
        _sentFpsLabel = [[UILabel alloc] init];
        _sentFpsLabel.textColor = [UIColor whiteColor];
        _sentFpsLabel.font = [UIFont systemFontOfSize:12];
    }
    return _sentFpsLabel;
}
- (UILabel *)encodeFpsLabel{
    if (!_encodeFpsLabel) {
        _encodeFpsLabel = [[UILabel alloc] init];
        _encodeFpsLabel.textColor = [UIColor whiteColor];
        _encodeFpsLabel.font = [UIFont systemFontOfSize:12];

    }
    return _encodeFpsLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
