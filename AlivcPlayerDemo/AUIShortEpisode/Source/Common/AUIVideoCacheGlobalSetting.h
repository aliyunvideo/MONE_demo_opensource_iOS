//
//  AUIVideoCacheGlobalSetting.h
//  AUIVideoList
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoCacheGlobalSetting : NSObject

/**
 设置全局本地缓存
 */
+ (void)setupCacheConfig;

/**
 删除全局本地缓存
 */
+ (void)clearCaches;

@end

NS_ASSUME_NONNULL_END
