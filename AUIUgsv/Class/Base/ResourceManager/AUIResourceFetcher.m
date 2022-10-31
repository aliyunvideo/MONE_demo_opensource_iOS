//
//  AUIResourceFetcher.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/7/7.
//

#import "AUIResourceFetcher.h"

@implementation AUIResourceFetcher

+ (AUIResourceFetcher *)defaultFetcher
{
    static AUIResourceFetcher *s_shared = nil;
    if (!s_shared) {
        s_shared = [AUIResourceFetcher new];
    }
    return s_shared;
}

+ (NSString *)resourceTypeName {
    return nil;
}

@end
