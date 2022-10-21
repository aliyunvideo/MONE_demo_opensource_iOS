//
//  AUIPhotoAlbumCell.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/27.
//

#import "AUIFoundation.h"
#import "AUIPhotoAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoAlbumCell : UICollectionViewCell

- (void)updateAlbumModel:(AUIPhotoAlbumModel *)albumModel;

@end

NS_ASSUME_NONNULL_END
