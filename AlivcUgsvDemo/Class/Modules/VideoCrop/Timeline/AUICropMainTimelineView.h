//
//  AUICropMainTimelineView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#import <UIKit/UIKit.h>
#import "AUIAssetPlay.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUICropMainTimelineView : UIView

- (instancetype)initWithFrame:(CGRect)frame withAssetPlayer:(AUIAssetPlay *)player;

@property (nonatomic, assign, readonly) NSTimeInterval clipStart;
@property (nonatomic, assign, readonly) NSTimeInterval clipEnd;

- (void)requestThumbnail:(NSTimeInterval)time completed:(void (^)(UIImage *image))completed;

@end

NS_ASSUME_NONNULL_END
