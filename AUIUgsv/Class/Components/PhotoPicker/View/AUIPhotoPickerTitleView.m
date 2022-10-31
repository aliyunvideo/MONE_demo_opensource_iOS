//
//  AUIPhotoPickerTitleView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/26.
//

#import "AUIPhotoPickerTitleView.h"
#import "AUIUgsvMacro.h"

@interface AUIPhotoPickerTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy) void (^selectChangedBlock)(BOOL selected);

@end


@implementation AUIPhotoPickerTitleView

- (instancetype)initWithSelectChangedBlock:(void (^)(BOOL))selectChangedBlock {
    self = [super init];
    if (self) {
        _selectChangedBlock = selectChangedBlock;
        
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.image = AUIUgsvPickerImage(@"ic_album");
        [self addSubview:_iconView];

        _titleLabel = [UILabel new];
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _titleLabel.font = AVGetMediumFont(14);
        _titleLabel.numberOfLines = 1;
        _titleLabel.text = @"";
        [self addSubview:_titleLabel];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
    
    [self.titleLabel sizeToFit];

    CGFloat iconHeight = 14;
    CGFloat height = MAX(self.titleLabel.av_height, iconHeight);
    
    self.titleLabel.frame = CGRectMake(0, (height - self.titleLabel.av_height) / 2.0, self.titleLabel.av_width, self.titleLabel.av_height);
    self.iconView.frame = CGRectMake(self.titleLabel.av_right + 2, (height - iconHeight) / 2.0, iconHeight, iconHeight);
    self.frame = CGRectMake(self.av_left, self.av_top, self.iconView.av_right, height);
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) {
        return;
    }
    _selected = selected;
    
    if (self.selectChangedBlock) {
        self.selectChangedBlock(self.selected);
    }
    self.iconView.transform = self.selected ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
    [UIView animateWithDuration:0.5 animations:^{
        self.iconView.transform = self.selected ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        self.iconView.transform = self.selected ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
    }];
}

- (void)onTap {
    self.selected = !self.selected;
}

@end
