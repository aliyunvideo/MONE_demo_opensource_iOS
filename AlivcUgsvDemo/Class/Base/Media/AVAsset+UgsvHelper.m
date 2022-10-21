//
//  AVAsset+UgsvHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/10.
//

#import "AVAsset+UgsvHelper.h"

@implementation AVAsset (UgsvHelper)

- (CGSize)ugsv_getResolution {
    CGRect unionRect = CGRectZero;
    for (AVAssetTrack *track in [self tracksWithMediaCharacteristic:AVMediaCharacteristicVisual]) {
        CGRect trackRect = CGRectApplyAffineTransform(CGRectMake(0.f,
                                                                 0.f,
                                                                 track.naturalSize.width,
                                                                 track.naturalSize.height),
                                                      track.preferredTransform);
        unionRect = CGRectUnion(unionRect, trackRect);
    }
    return unionRect.size;
}

- (NSTimeInterval)ugsv_getDuration {
    return CMTimeGetSeconds(self.duration);
}

@end
