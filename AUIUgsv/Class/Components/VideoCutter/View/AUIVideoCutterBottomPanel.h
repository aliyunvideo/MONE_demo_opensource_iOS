//
//  AUIVideoCutterBottomPanel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AUIVideoCutterBottomPanel;
@protocol AUICropBottomPanelDelegate <NSObject>
- (void) onAUICropBottomPanel:(AUIVideoCutterBottomPanel *)panel didConfirm:(BOOL)confirm;
@end

@protocol AUIVideoPlayProtocol;
@interface AUIVideoCutterBottomPanel : UIView
@property (nonatomic, readonly) NSTimeInterval startTime;
@property (nonatomic, weak) id<AUICropBottomPanelDelegate> delegate;
- (instancetype)initForImage;
- (instancetype)initWithPlayer:(nullable id<AUIVideoPlayProtocol>)player
                      filePath:(nullable NSString *)filePath
                  cropDuration:(NSTimeInterval)cropDuration;
@end

NS_ASSUME_NONNULL_END
