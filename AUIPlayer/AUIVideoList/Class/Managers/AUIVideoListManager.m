//
//  AUIVideoListManager.m
//  AliPlayerDemo
//
//  Created by zzy on 2022/3/23.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import "AUIVideoListManager.h"

#define AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey @"AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey"
#define AlivcPlayerFirstLaunch_AUIVideoList_BottomMoreTipKey @"AlivcPlayerFirstLaunch_AUIVideoList_BottomMoreTipKey"

@implementation AUIVideoListManager

+ (instancetype)manager {
    static AUIVideoListManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUIVideoListManager alloc] init];
    });
    return manager;
}

- (BOOL)isHideHandUp {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey];
}

- (BOOL)isHideBottomMoreTip {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:AlivcPlayerFirstLaunch_AUIVideoList_BottomMoreTipKey];
}

- (void)hideHandUp {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoList_HandUpKey];
}

- (void)showBottomMoreTip {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AlivcPlayerFirstLaunch_AUIVideoList_BottomMoreTipKey];
}

- (void)hideBottomMoreTip {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AlivcPlayerFirstLaunch_AUIVideoList_BottomMoreTipKey];
}

+ (NSArray<NSDictionary *> *)getSourceData {
    NSString *sourceDataPath = [[[NSBundle mainBundle] pathForResource:@"AUIVideoList" ofType:@"bundle"] stringByAppendingPathComponent:@"/Resource/videoList.json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:sourceDataPath];
    NSArray *sourceData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    return sourceData;
}

+ (NSArray<AUIVideoListModel *> *)convertSourceData {
    NSArray<NSDictionary *> *sourceData = [self getSourceData];
    __block NSMutableArray<AUIVideoListModel *> *sourceDataArr = [NSMutableArray array];
    [sourceData enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block AUIVideoListModel *listModel = [[AUIVideoListModel alloc] init];
        listModel.user = [obj objectForKey:@"user"];
        listModel.title = [obj objectForKey:@"title"];
        listModel.url = [obj objectForKey:@"url"];
        listModel.coverURL = [obj objectForKey:@"coverURL"];
        listModel.index = idx;
        [sourceDataArr addObject:listModel];
    }];
    return sourceDataArr.copy;
}

@end
