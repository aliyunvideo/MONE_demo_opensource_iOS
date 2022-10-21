//
//  AUIFilterView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AUIFilterModel;
@interface AUIFilterView : UIView<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, readonly) AUIFilterModel *currentSelected;
@property (nonatomic, copy) void(^onSelectedChanged)(AUIFilterModel *model);

- (void)updateDataSource:(NSArray *)list;
- (void)selectFilter:(AUIFilterModel *)filter;
- (void)selectWithIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
