//
//  AUITrackerThumbnailRequest.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/3.
//

#import <Foundation/Foundation.h>
#import "AUIAsyncImageGeneratorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUITrackerThumbnailRequestProtocol <NSObject>

- (void)requestTimes:(NSArray *)times duration:(NSTimeInterval)duration completed:(void(^)(NSTimeInterval time, UIImage *thumb))completed;

@end

@interface AUITrackerThumbnailRequest : NSObject<AUITrackerThumbnailRequestProtocol>

- (instancetype)initWithGenerator:(id<AUIAsyncImageGeneratorProtocol>)generator;

@end

NS_ASSUME_NONNULL_END
