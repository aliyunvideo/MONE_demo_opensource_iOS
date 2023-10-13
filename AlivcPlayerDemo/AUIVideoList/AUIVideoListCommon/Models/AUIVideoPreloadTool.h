//
//  AUIVideoPreloadTool.h
//  AUIVideoList
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AliMediaLoaderStatusDelegate;

@interface AUIVideoPreloadTool : NSObject

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
