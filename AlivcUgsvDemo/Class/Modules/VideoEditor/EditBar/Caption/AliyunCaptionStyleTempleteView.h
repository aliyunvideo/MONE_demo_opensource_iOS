//
//  AliyunCaptionStyleTempleteView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import <UIKit/UIKit.h>
#import "AUICaptionStyleTempleteModel.h"


NS_ASSUME_NONNULL_BEGIN



@interface AliyunCaptionStyleTempleteView : UIView
@property (nonatomic, readonly) AUICaptionStyleTempleteModel *currentSelected;
@property (nonatomic, copy) void (^onSelectedChanged)(AUICaptionStyleTempleteModel *model);
- (void)selectWithIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
