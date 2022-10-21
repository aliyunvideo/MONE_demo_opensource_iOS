//
//  AUIPhotoPickerBottomView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIFoundation.h"
#import "AUIPhotoAssetCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoPickerBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame
          withMaxPickingCount:(NSUInteger)maxPickingCount
        withAllowPickingImage:(BOOL)allowPickingImage
        withAllowPickingVideo:(BOOL)allowPickingVideo
           withAlbumModelList:(NSArray<AUIPhotoAssetCellItem *> *)selectedList
          withWillRemoveBlock:(void(^)(AUIPhotoAssetCellItem *item))willRemoveBlock
           withCompletedBlock:(void(^)(void))completedBlock;

- (void)reloadSelectedList;

@end

NS_ASSUME_NONNULL_END
