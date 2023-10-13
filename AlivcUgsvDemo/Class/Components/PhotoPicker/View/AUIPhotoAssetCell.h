//
//  AUIPhotoAssetCell.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#import "AUIFoundation.h"
#import "AUIPhotoAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoAssetCellItem : NSObject

@property (nonatomic, strong, readonly) AUIPhotoAssetModel *assetModel;

@property (nonatomic, assign) NSUInteger selectedIndex; // 0表示没选中
@property (nonatomic, assign) BOOL disableSelection;

- (instancetype)initWithAssetModel:(AUIPhotoAssetModel *)assetModel;

@end


@interface AUIPhotoAssetCell : UICollectionViewCell

- (void)updateItem:(AUIPhotoAssetCellItem *)item singleSelect:(BOOL)singleSelect;

- (void)refreshSelectionState;

@end

NS_ASSUME_NONNULL_END
