//
//  AUIPureImageCell.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import "AUIPureImageCell.h"
#import "AUIFoundation.h"
#import "Masonry.h"


@implementation AUIPureImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.contentView.layer.borderColor = AUIFoundationColor(@"colourful_border_strong").CGColor;
        self.contentView.layer.borderWidth = 1.f;
    } else {
        self.contentView.layer.borderWidth = 0.f;
    }
}


- (void)setup
{
    self.contentView.backgroundColor = AUIFoundationColor(@"fill_weak");
    self.contentView.layer.cornerRadius = 2.f;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).inset(5.0);
    }];
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _iconView;;
}

@end
