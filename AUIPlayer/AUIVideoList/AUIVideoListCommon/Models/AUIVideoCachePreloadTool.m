//
//  AUIVideoCachePreloadTool.m
//  AUIVideoList
//
//  Created by ISS013602000846 on 2022/11/9.
//

#import "AUIVideoCachePreloadTool.h"
#import<CommonCrypto/CommonDigest.h>

@implementation AUIVideoCachePreloadTool

+ (void)setLocalCacheConfig {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    [AliPlayerGlobalSettings enableLocalCache:YES maxBufferMemoryKB:10*1024 localCacheDir:[docDir stringByAppendingPathComponent:@"alicache"]];
    [AliPlayerGlobalSettings setCacheFileClearConfig:30*60*24 maxCapacityMB:20480 freeStorageMB:0];
    [AliPlayerGlobalSettings setCacheUrlHashCallback:_hashCallback];
}

+ (void)clearCaches {
    [AliPlayerGlobalSettings clearCaches];
}

NSString *_hashCallback(NSString* url){
    NSString *md5Str = [AUIVideoCachePreloadTool md5:url];
    return md5Str;
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    return  output;
}

+ (void)setPreloadConfig:(id<AliMediaLoaderStatusDelegate>)delegate {
    [[AliMediaLoader shareInstance] setAliMediaLoaderStatusDelegate:delegate];
}

+ (void)preloadUrl:(NSString *)url {
    [[AliMediaLoader shareInstance] load:url duration:1000];
}

+ (void)cancelPreloadUrl:(nullable NSString *)url {
    if (url && url.length > 0) {
        [[AliMediaLoader shareInstance] cancel:url];
    } else {
        [[AliMediaLoader shareInstance] cancel:nil];
    }
}

@end
