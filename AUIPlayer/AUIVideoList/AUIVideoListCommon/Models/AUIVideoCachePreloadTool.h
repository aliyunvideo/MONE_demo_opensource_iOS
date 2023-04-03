//
//  AUIVideoCachePreloadTool.h
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/11/9.
//

#import <Foundation/Foundation.h>

#define SCREEN [UIScreen mainScreen].bounds.size

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoCachePreloadTool : NSObject

/**
 设置全局本地缓存
 */
+ (void)setLocalCacheConfig;
/**
 删除全局本地缓存
 */
+ (void)clearCaches;
/**
 设置预加载
 @param delegate 预加载代理类
 */
+ (void)setPreloadConfig:(id<AliMediaLoaderStatusDelegate>)delegate;
/**
 设置预加载url
 @param url 预加载url
 */
+ (void)preloadUrl:(NSString *)url;
/**
 取消预加载url
 @param url 预加载url。url传入nil，则取消全部正在预加载的url。
 */
+ (void)cancelPreloadUrl:(nullable NSString *)url;

@end

NS_ASSUME_NONNULL_END
