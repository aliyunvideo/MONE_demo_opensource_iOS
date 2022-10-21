//
//  AUIMusicView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import <UIKit/UIKit.h>
#import "AUIVideoPlayProtocol.h"
#import "AUIMusicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIMusicView : UIView
@property (nonatomic, strong, nullable) id<AUIVideoPlayProtocol> player;
@property (nonatomic, readonly) NSTimeInterval limitDuration;
@property (nonatomic, strong, nullable) AUIMusicSelectedModel *currentSelected;
@property (nonatomic, copy) void(^onSelectedChanged)(AUIMusicSelectedModel * _Nullable model);
@property (nonatomic, assign) BOOL isShowing;

- (instancetype)initWithLimitDuration:(NSTimeInterval)limitDuration;
@end

NS_ASSUME_NONNULL_END
