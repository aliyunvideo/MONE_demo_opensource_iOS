//
//  AUISpeedChangedControllPanel.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/2.
//

#import "AVBaseControllPanel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUISpeedChangedControllPanel : AVBaseControllPanel
@property (nonatomic, copy) void (^onValueChanged)(float value);
@property (nonatomic, assign, readonly) float curentValue;

- (void)updateCurentValue:(float)value;



@end

NS_ASSUME_NONNULL_END
