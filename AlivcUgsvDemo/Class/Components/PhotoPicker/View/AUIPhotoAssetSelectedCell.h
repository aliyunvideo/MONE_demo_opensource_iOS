//
//  AUIPhotoAssetSelectedCell.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIPhotoAssetCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoAssetSelectedCell : UICollectionViewCell

- (void)updateItem:(AUIPhotoAssetCellItem *)item;

@property (nonatomic, copy) void(^willRemoveBlock)(AUIPhotoAssetCellItem *item);

@end

NS_ASSUME_NONNULL_END
