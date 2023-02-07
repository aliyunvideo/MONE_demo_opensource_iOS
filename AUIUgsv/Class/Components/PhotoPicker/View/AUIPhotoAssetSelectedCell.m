//
//  AUIPhotoAssetSelectedCell.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIPhotoAssetSelectedCell.h"
#import "AUIUgsvMacro.h"

@implementation AUIPhotoAssetSelectedItem

- (NSTimeInterval)assetDuration {
    if (_assetDuration > 0) {
        return _assetDuration;
    }
    if (self.asset) {
        return self.asset.assetModel.assetDuration;
    }
    return 0;
}

- (UIImage *)thumbnailImage {
    if (self.asset) {
        return self.asset.assetModel.thumbnailImage;
    }
    return nil;
}

@end



@interface AUIPhotoAssetSelectedCell ()

@property (nonatomic, strong) AUIPhotoAssetSelectedItem *currentItem;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, strong) UILabel *durationView;
@property (nonatomic, strong) UIButton *deleteView;

@end

@implementation AUIPhotoAssetSelectedCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _bgView = [UIView new];
        _bgView.backgroundColor = AUIFoundationColor(@"fill_medium");
        _bgView.layer.borderColor = AUIFoundationColor(@"colourful_fg_strong").CGColor;
        _bgView.layer.cornerRadius = 2.0;
        _bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bgView];
        
        _thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thumbView.contentMode = UIViewContentModeScaleAspectFill;
        [_bgView addSubview:_thumbView];
        
        _durationView = [[UILabel alloc] initWithFrame:CGRectZero];
        _durationView.textColor = AUIFoundationColor(@"text_strong");
        _durationView.font = AVGetMediumFont(12);
        [_bgView addSubview:_durationView];
        
        _deleteView = [[UIButton alloc] initWithFrame:CGRectZero];
        [_deleteView setImage:AUIUgsvPickerImage(@"ic_remove") forState:UIControlStateNormal];
        [_deleteView addTarget:self action:@selector(onDeletedClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteView];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgView.frame = CGRectMake(0, 8, 52, 52);
    self.thumbView.frame = self.bgView.bounds;
    
    [self.durationView sizeToFit];
    if (self.currentItem.durationMode) {
        self.durationView.center = self.thumbView.center;
    }
    else {
        self.durationView.frame = CGRectMake(self.bgView.av_right - self.durationView.av_width - 4, self.bgView.av_height - self.durationView.av_height - 4, self.durationView.av_width, self.durationView.av_height);
    }
    
    self.deleteView.frame = CGRectMake(self.contentView.av_width - 20, 0, 20, 20);
}

- (void)updateItem:(AUIPhotoAssetSelectedItem *)item {
    self.currentItem = item;
    
    self.bgView.layer.borderWidth = self.currentItem.selected ? 1.0 : 0;
    self.thumbView.image = self.currentItem.thumbnailImage;
    if (self.currentItem.durationMode) {
        self.durationView.text = [NSString stringWithFormat:@"%.1fs", self.currentItem.assetDuration];
        self.thumbView.alpha = 0.4;
    }
    else {
        self.durationView.text = [AVStringFormat formatWithDuration:item.assetDuration];
        self.thumbView.alpha = 1.0;
    }
    self.deleteView.hidden = self.currentItem.asset == nil;
    
    [self setNeedsLayout];
}

- (void)onDeletedClicked:(UIButton *)sender {
    if (self.willRemoveBlock) {
        self.willRemoveBlock(self.currentItem);
    }
}

@end
