//
//  AUIPhotoAssetSelectedCell.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIPhotoAssetCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoAssetSelectedItem : NSObject

@property (nonatomic, assign) NSTimeInterval assetDuration;
@property (nonatomic, strong, readonly) UIImage *thumbnailImage;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL durationMode;

@property (nonatomic, strong, nullable) AUIPhotoAssetCellItem *asset;

@end


@interface AUIPhotoAssetSelectedCell : UICollectionViewCell

- (void)updateItem:(AUIPhotoAssetSelectedItem *)item;

@property (nonatomic, copy) void(^willRemoveBlock)(AUIPhotoAssetSelectedItem *item);



@end

NS_ASSUME_NONNULL_END
