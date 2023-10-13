//
//  AUIVideoPreloadTool.m
//  AUIVideoList
//
//

#import "AUIVideoPreloadTool.h"
#import<CommonCrypto/CommonDigest.h>

@implementation AUIVideoPreloadTool

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
