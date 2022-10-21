//
//  AUIPhotoAssetSelectedCell.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIPhotoAssetSelectedCell.h"
#import "AUIUgsvMacro.h"


@interface AUIPhotoAssetSelectedCell ()

@property (nonatomic, strong) AUIPhotoAssetCellItem *currentItem;

@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, strong) UILabel *durationView;
@property (nonatomic, strong) UIButton *deleteView;

@end

@implementation AUIPhotoAssetSelectedCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thumbView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _thumbView.layer.cornerRadius = 2.0;
        _thumbView.layer.masksToBounds = YES;
        [self.contentView addSubview:_thumbView];
        
        _durationView = [[UILabel alloc] initWithFrame:CGRectZero];
        _durationView.textColor = AUIFoundationColor(@"text_strong");
        _durationView.font = AVGetRegularFont(8);
        [_thumbView addSubview:_durationView];
        
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
    
    self.thumbView.frame = CGRectMake(0, 8, 52, 52);
    
    [self.durationView sizeToFit];
    self.durationView.frame = CGRectMake(self.thumbView.av_right - self.durationView.av_width - 4, self.thumbView.av_height - 4 - 6, self.durationView.av_width, 6);
    
    self.deleteView.frame = CGRectMake(self.contentView.av_width - 20, 0, 20, 20);
}

- (void)updateItem:(AUIPhotoAssetCellItem *)item {
    self.currentItem = item;
    
    self.durationView.text = [AVStringFormat formatWithDuration:item.assetModel.assetDuration];
    [self setNeedsLayout];
    
    self.thumbView.image = self.currentItem.assetModel.thumbnailImage;
}

- (void)onDeletedClicked:(UIButton *)sender {
    if (self.willRemoveBlock) {
        self.willRemoveBlock(self.currentItem);
    }
}

@end
