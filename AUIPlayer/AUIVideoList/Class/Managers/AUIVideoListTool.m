//
//  AUIVideoListTool.m
//  AliPlayerDemo
//
//  Created by 郦立 on 2018/12/29.
//  Copyright © 2018年 com.alibaba. All rights reserved.
//

#import "AUIVideoListTool.h"
#import <CommonCrypto/CommonDigest.h>

#define Cache_dir_KEY           @"ud_key_Cache_dir"
#define Cache_size_KEY          @"ud_key_Cache_size"
#define Cache_enable_KEY          @"ud_key_Cache_enable"

#define Cache_expireMin_KEY          @"ud_key_Cache_expireMin"
#define Cache_maxCapacityMB_KEY          @"ud_key_Cache_maxCapacityMB"
#define Cache_freeStorageMB_KEY          @"ud_key_Cache_freeStorageMB"

#define isInstall_KEY           @"isInstall_KEY"
#define EnableHttpDns_KEY @"EnableHttpDns_KEY"

@implementation AUIVideoListTool

+(NSString*)getCacheDir{
    return [[NSUserDefaults standardUserDefaults] stringForKey:Cache_dir_KEY];
}

+(NSInteger)getCacheSize{
    return [[NSUserDefaults standardUserDefaults] integerForKey:Cache_size_KEY];
}

+(BOOL)getCacheEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:Cache_enable_KEY];
}

+(void)enableLocalCache:(bool)enable maxBufferMemoryMB:(int)maxBufferMemoryMB localCacheDir:(NSString *)localCacheDir{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    if (localCacheDir.length>0) {
        [[NSUserDefaults standardUserDefaults] setObject:localCacheDir forKey:Cache_dir_KEY];
    }
    [AliPlayerGlobalSettings enableLocalCache:enable maxBufferMemoryKB:maxBufferMemoryMB*1024 localCacheDir:[docDir stringByAppendingPathComponent:localCacheDir]];
    [[NSUserDefaults standardUserDefaults] setInteger:maxBufferMemoryMB forKey:Cache_size_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:Cache_enable_KEY];
}

+(NSInteger)getExpireMin{
    return [[NSUserDefaults standardUserDefaults] integerForKey:Cache_expireMin_KEY];
}

+(NSInteger)getMaxCapacityMB{
    return [[NSUserDefaults standardUserDefaults] integerForKey:Cache_maxCapacityMB_KEY];
}

+(NSInteger)getFreeStorageMB{
    return [[NSUserDefaults standardUserDefaults] integerForKey:Cache_freeStorageMB_KEY];
}

+ (void)setCacheFileClearConfig:(int64_t)expireMin maxCapacityMB:(int64_t)maxCapacityMB freeStorageMB:(int64_t)freeStorageMB{
    [AliPlayerGlobalSettings setCacheFileClearConfig:expireMin*60*24 maxCapacityMB:maxCapacityMB freeStorageMB:freeStorageMB];
    [[NSUserDefaults standardUserDefaults] setInteger:expireMin forKey:Cache_expireMin_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:maxCapacityMB forKey:Cache_maxCapacityMB_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:freeStorageMB forKey:Cache_freeStorageMB_KEY];
}

- (void)setDefalutCache{
    [AUIVideoListTool enableLocalCache:YES maxBufferMemoryMB:10 localCacheDir:@"alicache"];
    [AUIVideoListTool setCacheFileClearConfig:30 maxCapacityMB:20480 freeStorageMB:0];
    [AliPlayerGlobalSettings setCacheUrlHashCallback:hashCallback];
}

NSString* hashCallback(NSString* url){
    NSString *md5Str = [AUIVideoListTool md5:url];
    // NSLog(@"preLoad = LoadURLHashBlock=====> url:%@  md5:%@",url,md5Str);
    return md5Str;
}

+ (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    return  output;
}

// 获取path路径下文件夹大小
+ (NSString *)getCacheSizeWithFilePath:(NSString *)path{
    
    // 获取“path”文件夹下的所有文件
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    
    NSString *filePath  = nil;
    NSInteger totleSize = 0;
    
    for (NSString *subPath in subPathArr){
        
        // 1. 拼接每一个文件的全路径
        filePath =[path stringByAppendingPathComponent:subPath];
        // 2. 是否是文件夹，默认不是
        BOOL isDirectory = NO;
        // 3. 判断文件是否存在
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // 4. 以上判断目的是忽略不需要计算的文件
        if (!isExist || isDirectory || [filePath containsString:@".DS"]){
            // 过滤: 1. 文件夹不存在  2. 过滤文件夹  3. 隐藏文件
            continue;
        }
        
        // 5. 指定路径，获取这个路径的属性
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         attributesOfItemAtPath: 文件夹路径
         该方法只能获取文件的属性, 无法获取文件夹属性, 所以也是需要遍历文件夹的每一个文件的原因
         */
        
        // 6. 获取每一个文件的大小
        NSInteger size = [dict[@"NSFileSize"] integerValue];
        
        // 7. 计算总大小
        totleSize += size;
    }
    
    //8. 将文件夹大小转换为 M/KB/B
    NSString *totleStr = nil;
    
    if (totleSize > 1000 * 1000){
        totleStr = [NSString stringWithFormat:@"%.2fM",totleSize / 1000.00f /1000.00f];
        
    }else if (totleSize > 1000){
        totleStr = [NSString stringWithFormat:@"%.2fKB",totleSize / 1000.00f ];
        
    }else{
        totleStr = [NSString stringWithFormat:@"%.2fB",totleSize / 1.00f];
    }
    
    return totleStr;
}


//清除path文件夹下缓存大小
+ (BOOL)clearCacheWithFilePath:(NSString *)path{
    
    //拿到path路径的下一级目录的子文件夹
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    NSString *filePath = nil;
    
    NSError *error = nil;
    
    for (NSString *subPath in subPathArr)
    {
        filePath = [path stringByAppendingPathComponent:subPath];
        
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}

@end






