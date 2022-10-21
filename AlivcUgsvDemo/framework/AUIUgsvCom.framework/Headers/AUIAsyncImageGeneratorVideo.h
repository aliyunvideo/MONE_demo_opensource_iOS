//
//  AUIAsyncImageGeneratorVideo.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#import "AUIAsyncImageGeneratorProtocol.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIAsyncImageGeneratorVideo : NSObject<AUIAsyncImageGeneratorProtocol>

- (instancetype)initWithPath:(NSString *)filePath;
- (instancetype)initWithAsset:(AVAsset *)asset;

@end

NS_ASSUME_NONNULL_END
