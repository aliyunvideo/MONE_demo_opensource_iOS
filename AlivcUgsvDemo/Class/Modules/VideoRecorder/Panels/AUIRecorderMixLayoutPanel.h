//
//  AUIRecorderMixLayoutPanel.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2023/11/20.
//

#import "AVBaseControllPanel.h"
#import "AUIRecorderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRecorderMixLayoutPanel : AVBaseControllPanel

- (instancetype)initWithFrame:(CGRect)frame mixType:(AUIRecorderMixType)mixType;

@property (nonatomic, copy) void(^onMixTypeChanged)(AUIRecorderMixType mixType);

@end

NS_ASSUME_NONNULL_END
