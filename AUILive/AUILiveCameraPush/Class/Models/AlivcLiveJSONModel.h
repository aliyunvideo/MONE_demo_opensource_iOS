//
//  JSONModel.h
//  QupaiSDK
//
//  Created by yly on 15/6/26.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlivcLiveJSONModel : NSObject

/**
 *  创建JSONModel
 *
 *  @param dic   数据字典
 *  @return      JSONModel
 */
- (instancetype)initWithDictionary:(NSDictionary *)dic;

/**
 *  转换字典
 *
 *  @return      数据字典
 */
- (NSDictionary *)toDictionary;


/**
 *  转换字符串
 *
 *  @return      字符串
 */
- (NSString *)toString;

/**
 *  创建JSONModel
 *
 *  @param path   文件路径
 *  @return       JSONModel
 */
- (instancetype)initWithFile:(NSString *)path;

/**
 *  文件写入数据
 *
 *  @param path 路径
 */
- (void)jsonToFile:(NSString *)path;

@end
