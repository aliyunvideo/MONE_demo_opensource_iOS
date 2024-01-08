//
//  AUIFilterCell.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import "AUIFilterCell.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"
#import "AUIFilterModel.h"

@interface AUIFilterCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *selectedMaskView;
@end

@implementation AUIFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
    // clear
    [_iconView removeFromSuperview];
    [_titleLabel removeFromSuperview];
    [_selectedMaskView removeFromSuperview];

    // create
    self.contentView.layer.cornerRadius = 2.0;
    self.contentView.layer.masksToBounds = YES;
    
    _iconView = [UIImageView new];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).inset(20);
    }];
    
    _titleLabel = [UILabel new];
    _titleLabel.backgroundColor = UIColor.clearColor;
    _titleLabel.font = AVGetRegularFont(12.0);
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
    _selectedMaskView = [[UIImageView alloc] initWithImage:AUIUgsvGetImage(@"ic_panel_cell_selected")];
    _selectedMaskView.backgroundColor = AUIFoundationColor(@"tsp_fill_weak");
    [self.contentView addSubview:_selectedMaskView];
    [_selectedMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_iconView);
    }];

    // update
    [self updateUI];
}

- (void) setModel:(AUIFilterModel *)model {
    if (_model == model) {
        return;
    }
    _model = model;
    self.titleLabel.text = model.name;
    if (model.isEmpty) {
        self.iconView.image = AUIUgsvGetImage(@"ic_panel_clear");
    }
    else {
        self.iconView.image = [UIImage imageWithContentsOfFile:model.iconPath];
        if (!self.iconView.image) {
            self.iconView.image = AUIUgsvGetImage(model.iconPath);
            [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_equalTo(24);
                            make.height.mas_equalTo(24);
                            make.centerX.equalTo(self.contentView);
                            make.centerY.equalTo(self.contentView).offset(-10);
                        }];
        }
    }
}

- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateUI];
}

- (void) updateUI {
    self.selectedMaskView.alpha = self.isSelected ? 1.0 : 0.0;
    if (self.isSelected) {
        self.contentView.backgroundColor = AUIFoundationColor(@"fill_weak");
        self.titleLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    } else {
        self.contentView.backgroundColor = AUIFoundationColor(@"fill_medium");
        self.titleLabel.textColor = AUIFoundationColor(@"text_strong");
    }
}

@end
