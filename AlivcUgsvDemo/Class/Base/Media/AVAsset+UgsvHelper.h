//
//  AVAsset+UgsvHelper.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/10.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (UgsvHelper)

- (CGSize)ugsv_getResolution;
- (NSTimeInterval)ugsv_getDuration;

@end

NS_ASSUME_NONNULL_END
