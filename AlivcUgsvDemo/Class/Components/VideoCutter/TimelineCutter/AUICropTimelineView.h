//
//  AUICropTimelineView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUIVideoPlayProtocol;
@interface AUICropTimelineView : UIView
@property (nonatomic, readonly) NSTimeInterval startTime;
- (instancetype)initWithPlayer:(id<AUIVideoPlayProtocol>)player
                  cropDuration:(NSTimeInterval)duration
                      filePath:(NSString *)filePath;
@end

NS_ASSUME_NONNULL_END
