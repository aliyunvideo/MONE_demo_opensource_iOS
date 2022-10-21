//
//  AUIMediaTokenService.h
//  qusdk
//
//  Created by Worthy Zhang on 2019/1/2.
//  Copyright © 2019 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#warning 尊敬的客户，AUIMediaTokenService使用的域名及接口只用于demo演示使用，在集成到APP时请搭建自己的Server服务，此次仅供参考。如何集成自己的Server服务详见文档：https://help.aliyun.com/document_detail/108783.html?spm=a2c4g.11186623.6.1075.a70a3a4895Qysq。

@interface AUIMediaTokenService : NSObject


/**
 获取图片上传的凭证

 @param tokenString 用户token
 @param title 标题
 @param filePath 图片路径
 @param tags tag-标签
 @param handler 回调
 */
+ (void)getImageUploadAuthWithToken:(NSString *_Nullable)tokenString
                              title:(NSString * _Nullable)title
                           filePath:(NSString *)filePath
                               tags:(NSString * _Nullable)tags
                            handler:(void (^)(NSString *_Nullable uploadAddress, NSString *_Nullable uploadAuth, NSString *_Nullable imageURL, NSString *_Nullable imageId, NSError *_Nullable error))handler;


/**
 获取视频上传的凭证

 @param tokenString 用户token
 @param title 视频标题
 @param filePath 视频路径
 @param coverURL 封面图
 @param desc 描述
 @param tags tag-标签
 @param handler 回调
 */
+ (void)getVideoUploadAuthWithWithToken:(NSString *_Nullable)tokenString
                                  title:(NSString *)title
                               filePath:(NSString *)filePath
                               coverURL:(NSString * _Nullable)coverURL
                                   desc:(NSString *_Nullable)desc
                                   tags:(NSString * _Nullable)tags
                                handler:(void (^)(NSString *_Nullable uploadAddress, NSString *_Nullable uploadAuth, NSString *_Nullable videoId, NSError *_Nullable error))handler;

/**
 刷新视频上传凭证

 @param tokenString 用户凭证
 @param videoId 视频id
 @param handler 回调
 */
+ (void)refreshVideoUploadAuthWithToken:(NSString *_Nullable)tokenString
                                videoId:(NSString *)videoId
                                handler:(void (^)(NSString *_Nullable uploadAddress, NSString *_Nullable uploadAuth, NSError *_Nullable error))handler;



@end

NS_ASSUME_NONNULL_END
