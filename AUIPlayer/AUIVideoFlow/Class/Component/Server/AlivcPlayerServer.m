//
//  AlivcPlayerServer.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import "AlivcPlayerServer.h"

#define ENABLE_TEST_SERVER  2

@implementation AlivcPlayerServer

+ (NSString *)host {

    switch (ENABLE_TEST_SERVER) {
        case 0:
            return @"http://vpdemo-proxy.aliyun.test";
        case 1:
            return @"https://pre-vpdemo-proxy.aliyuncs.com";
        case 2:
            return @"https://vpdemo-proxy.aliyuncs.com";
        default:
            return @"http://vpdemo-proxy.aliyun.test";
            break;
    }
}

+ (NSString *)urlWithPath:(NSString *)path {
    return [[self host] stringByAppendingPathComponent:path];
}

@end
