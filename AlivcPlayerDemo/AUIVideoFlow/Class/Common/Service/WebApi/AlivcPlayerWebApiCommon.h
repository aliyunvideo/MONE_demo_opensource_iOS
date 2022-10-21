//
//  AlivcPlayerWebApiCommon.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, APWebApiResultCode)
{
    // 服务端响应客户端成功
    APWebApiResCodeSucceed = 20000,
    
    // 服务端响应客户端错误
    APWebApiResCodeCustomerError = 40000,
    
    // 服务端响应服务端错误
    APWebApiResCodeServerError = 50000,

    
    // 客户端处理出错
    APWebApiCustomCodeUnknow = 99900,  //未知错误
    APWebApiCustomCodeMissParam,        //缺少参数
    APWebApiCustomCodeFormat,           //格式错误
    APWebApiCustomCodeInvalidParam,     //包含非法参数
    APWebApiCustomCodeInvalidParamLen,  //参数内容长度不合法
    APWebApiCustomCodeObjNotExist,      //对象不存在
    APWebApiCustomCodeUserUnLogin,      //用户未登录
    APWebApiCustomCodeActionForbidden,  //操作不允许
    APWebApiCustomCodeFrequent,         //操作太频繁
    APWebApiCustomCodeNetwork,          //网络错误
    APWebApiCustomCodeJsonParse,        //json解析错误
    APWebApiCustomCodeJsonLostParam,    //json缺少参数
};

extern NSString* APWebApiErrorDomain;

@interface NSError (APWebApi)

+ (NSError*)ap_webApiErrorWithCode:(APWebApiResultCode)code desc:(nullable NSString *)desc;

@end

NS_ASSUME_NONNULL_END
