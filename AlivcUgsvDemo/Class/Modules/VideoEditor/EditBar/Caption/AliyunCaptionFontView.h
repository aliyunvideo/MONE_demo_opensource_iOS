//
//  AliyunCaptionFontView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import <UIKit/UIKit.h>

@class AUICaptionFontModel;

NS_ASSUME_NONNULL_BEGIN

@interface AliyunCaptionFontView : UIView
@property (nonatomic, readonly) AUICaptionFontModel *currentSelected;
@property (nonatomic, readonly) NSMutableArray *dataList;
@property (nonatomic, copy) void (^onSelectedChanged)(AUICaptionFontModel *model);
- (void)selectWithIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
