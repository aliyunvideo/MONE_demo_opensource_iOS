//
//  AUITrackerTitleViewLoader.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUITrackerTitleViewLoaderProtocol <NSObject>

- (UIView *)loadTitleView;

@end

@interface AUITrackerTitleViewLoader : NSObject<AUITrackerTitleViewLoaderProtocol>

@end

NS_ASSUME_NONNULL_END
