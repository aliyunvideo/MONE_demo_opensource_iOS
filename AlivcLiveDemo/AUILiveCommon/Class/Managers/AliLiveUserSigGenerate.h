//
//  AliLiveUserSigGenerate.h
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/8/8.
//

#ifndef AliLiveUserSigGenerate_h
#define AliLiveUserSigGenerate_h

#import <Foundation/Foundation.h>

/**
 *  AppID
 *  应用ID。在直播控制台连麦应用管理页面创建和查看。
 */
static NSString * const ALILIVE_APPID = @"PLACEHOLDER";

/**
 *  AppKey
 *  在直播控制台连麦应用管理页面创建和查看。
 */
static NSString * const ALILIVE_APPKey = @"PLACEHOLDER";

/**
 *  配置拉流地址
 *  在直播控制台连麦应用管理页面创建和查看。
 */
static NSString * const ALILIVE_PLAY_DOMAIN = @"PLACEHOLDER";

/**
 *  rtc签名过期时间
 *  时间单位秒，代表令牌有效时间。可设置最大范围是小于等于1天，建议不要设置的过短或超过1天，超过1天会不安全。
 *  默认时间1天。1天 = 60 x  60  x 24。
 */
static const long ALILIVE_TIMESTAMP = 60 * 60 * 24;


#endif /* AliLiveUserSigGenerate_h */
