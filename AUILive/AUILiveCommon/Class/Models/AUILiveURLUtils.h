//
//  AUILiveURLUtils.h
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/8/2.
//

#import <Foundation/Foundation.h>
#import "AliLiveUserSigGenerate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveURLUtils : NSObject

/**
 *  流类型
 *  默认CDN。NO：CDN，YES：RTC
 */
@property (nonatomic, assign) BOOL isRTC;
/**
 *  URL类型
 *  默认推流。NO：推流，YES：拉流
 */
@property (nonatomic, assign) BOOL isPlay;
/**
 *  用户ID
 */
@property (nonatomic, strong) NSString *userId;
/**
 *  房间号
 */
@property (nonatomic, strong) NSString *streamName;
/**
 * 是否是纯音频
 */
@property (nonatomic, assign) BOOL isAudioOnly;

- (NSString *)getRTCURL;
- (NSString *)getCDNURL;

@end

NS_ASSUME_NONNULL_END
