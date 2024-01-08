//
//  AUITextCollectionViewCell.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import "AUITextCollectionViewCell.h"
#import "Masonry.h"
#import "AUIFoundation.h"


@implementation AUITextCollectionViewCell

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
    self.contentView.layer.cornerRadius = 2.f;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).inset(0.0);
    }];
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 1;
        _textLabel.textColor = AUIFoundationColor(@"text_strong");
    }
    
    return _textLabel;;
}

@end
