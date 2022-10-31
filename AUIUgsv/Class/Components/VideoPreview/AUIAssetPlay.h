//
//  AUIAssetPlay.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/1.
//

#import <Foundation/Foundation.h>
#import "AUIVideoPlayProtocol.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface AUIAssetPlay : NSObject<AUIVideoPlayProtocol>

- (instancetype)initWithAsset:(AVAsset *)asset;

@property (nonatomic, strong, readonly) AVAsset *playAsset;

@end

NS_ASSUME_NONNULL_END
