//
//  AUIStickerView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AUIStickerModel;
@interface AUIStickerView : UIView
@property (nonatomic, readonly) AUIStickerModel *currentSelected;
@property (nonatomic, readonly) NSMutableArray *dataList;
@property (nonatomic, copy) void (^onSelectedChanged)(AUIStickerModel *model);
- (void)updateDataSource:(NSArray *)list;
- (void)selectWithIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
