//
//  AUIPanelStatusButtonView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIPanelStatusButtonView : UIView

@property (nonatomic, copy) void(^onConfirmBlock)(void);
@property (nonatomic, copy) void(^onCancelBlock)(void);

@end

NS_ASSUME_NONNULL_END
