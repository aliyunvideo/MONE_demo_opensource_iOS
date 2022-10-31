//
//  AUITrackerHeaderViewLoader.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUITrackerHeaderViewLoaderProtocol <NSObject>

- (UIView *)loadHeaderView;

@end

@interface AUITrackerHeaderViewLoader : NSObject<AUITrackerHeaderViewLoaderProtocol>

@end

NS_ASSUME_NONNULL_END
