//
//  AUIPhotoAssetCell.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#import "AUIPhotoAssetCell.h"
#import "AUIPhotoLibraryManager.h"
#import "AUIUgsvMacro.h"

@implementation AUIPhotoAssetCellItem

- (instancetype)initWithAssetModel:(AUIPhotoAssetModel *)assetModel {
    self = [super init];
    if (self) {
        _assetModel = assetModel;
    }
    return self;
}

@end



@interface AUIPhotoAssetCell ()

@property (nonatomic, strong) AUIPhotoAssetCellItem *currentItem;
@property (nonatomic, strong) AUIPhotoAssetCellItem *fetchingItem;

@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, strong) UILabel *durationView;
@property (nonatomic, strong) UIButton *selectionFlagView;

@end

@implementation AUIPhotoAssetCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thumbView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _thumbView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbView];
        
        _durationView = [[UILabel alloc] initWithFrame:CGRectZero];
        _durationView.backgroundColor = AUIFoundationColor2(@"bg_medium", 0.6);
        _durationView.textColor = AUIFoundationColor(@"text_strong");
        _durationView.textAlignment = NSTextAlignmentCenter;
        _durationView.font = AVGetRegularFont(11);
        _durationView.layer.cornerRadius = 8;
        _durationView.layer.masksToBounds = YES;
        [_thumbView addSubview:_durationView];
        
        _selectionFlagView = [[UIButton alloc] initWithFrame:CGRectZero];
        _selectionFlagView.userInteractionEnabled = NO;
        _selectionFlagView.layer.cornerRadius = 9.0;
        _selectionFlagView.clipsToBounds = YES;
        _selectionFlagView.titleLabel.font = AVGetSemiboldFont(12);
        [_selectionFlagView setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [self.contentView addSubview:_selectionFlagView];

        _selectionFlagView.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
        [_selectionFlagView av_setLayerBorderColor:AUIFoundationColor(@"fill_infrared") borderWidth:2.0];
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.thumbView.frame = self.contentView.bounds;
    
    [self.durationView sizeToFit];
    self.durationView.frame = CGRectMake(self.thumbView.av_width - self.durationView.av_width - 6 - 10, self.thumbView.av_height - 6 -16, self.durationView.av_width + 10, 16);
    
    self.selectionFlagView.frame = CGRectMake(self.contentView.av_width - 18 - 4, 4, 18, 18);
}

- (void)updateItem:(AUIPhotoAssetCellItem *)item singleSelect:(BOOL)singleSelect {
    self.currentItem = item;
    
    self.selectionFlagView.hidden = singleSelect;
    
    self.durationView.text = [AVStringFormat formatWithDuration:item.assetModel.assetDuration];
    self.durationView.hidden = item.assetModel.type == AUIPhotoAssetTypePhoto;
    [self setNeedsLayout];
    
    if (self.currentItem.assetModel.thumbnailImage) {
        self.thumbView.image = self.currentItem.assetModel.thumbnailImage;
        self.fetchingItem = nil;
    }
    else {
        self.fetchingItem = self.currentItem;
        __weak typeof(self) weakSelf = self;
        [AUIPhotoLibraryManager getPhotoWithAsset:self.fetchingItem.assetModel.asset photoWidth:80.0 completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info, BOOL isDegraded) {
            if (isDegraded) {
                return;
            }
            weakSelf.fetchingItem.assetModel.thumbnailImage = photo;
            if (weakSelf.currentItem == weakSelf.fetchingItem) {
                weakSelf.thumbView.image = photo;
            }
            else {
                NSLog(@"当前model被更新了");
            }
        }];
    }
    
    [self refreshSelectionState];
}

- (void)refreshSelectionState {
    
    if (self.currentItem.disableSelection) {
        // 不可选状态
        self.contentView.alpha = 0.4;
        self.thumbView.alpha = 1.0;
        
        self.selectionFlagView.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
        [self.selectionFlagView av_setLayerBorderColor:AUIFoundationColor(@"fill_infrared")];
        [self.selectionFlagView setTitle:@"" forState:UIControlStateNormal];
    }
    else if (self.currentItem.selectedIndex > 0 && !self.selectionFlagView.hidden) {
        // 已选中状态
        self.contentView.alpha = 1.0;
        self.thumbView.alpha = 0.7;
        
        self.selectionFlagView.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        [self.selectionFlagView av_setLayerBorderColor:AUIFoundationColor(@"colourful_fill_strong")];
        [self.selectionFlagView setTitle:[NSString stringWithFormat:@"%tu", self.currentItem.selectedIndex] forState:UIControlStateNormal];
    }
    else {
        // 可选状态
        self.contentView.alpha = 1.0;
        self.thumbView.alpha = 1.0;
        
        self.selectionFlagView.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
        [self.selectionFlagView av_setLayerBorderColor:AUIFoundationColor(@"fill_infrared")];
        [self.selectionFlagView setTitle:@"" forState:UIControlStateNormal];
    }
}

@end
