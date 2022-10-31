//
//  AUIVideoListTool.h
//  AliPlayerDemo
//
//  Created by 郦立 on 2018/12/29.
//  Copyright © 2018年 com.alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AUIVideoListTool : NSObject

+ (NSString*)getCacheDir;

+ (NSInteger)getCacheSize;

+(BOOL)getCacheEnable;

+(void)enableLocalCache:(bool)enable maxBufferMemoryMB:(int)maxBufferMemoryKB localCacheDir:(NSString *)localCacheDir;

+(NSInteger)getExpireMin;

+(NSInteger)getMaxCapacityMB;

+(NSInteger)getFreeStorageMB;

+ (void)setCacheFileClearConfig:(int64_t)expireMin maxCapacityMB:(int64_t)maxCapacityMB freeStorageMB:(int64_t)freeStorageMB;

- (void)setDefalutCache;

+ (NSString *)getCacheSizeWithFilePath:(NSString *)path;
+ (BOOL)clearCacheWithFilePath:(NSString *)path;

+ (NSString *) md5:(NSString *) input;

@end






