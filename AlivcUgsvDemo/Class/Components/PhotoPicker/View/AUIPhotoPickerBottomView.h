//
//  AUIPhotoPickerBottomView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIFoundation.h"
#import "AUIPhotoAssetSelectedCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoPickerBottomView : UIView

@property (nonatomic, copy) NSAttributedString *attributeText;
@property (nonatomic, copy) NSArray<AUIPhotoAssetSelectedItem *> *selectedList;

- (instancetype)initWithFrame:(CGRect)frame
          withWillRemoveBlock:(void(^)(AUIPhotoAssetSelectedItem *item))willRemoveBlock
           withCompletedBlock:(void(^)(void))completedBlock;

- (void)reloadSelectedList;

@end

NS_ASSUME_NONNULL_END
