//
//  AUIRecorderProgressView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRecorderProgressView : UIView
@property (nonatomic, assign) NSTimeInterval maxDuration;
@property (nonatomic, readonly) NSTimeInterval totalDuration;
@property (nonatomic, copy) NSArray<NSNumber *> *partDurations;
@property (nonatomic, assign) NSTimeInterval currentPartDuration;
@end

NS_ASSUME_NONNULL_END
