//
//  AlivcPlayerVideoDBManager.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayerVideoDBModel.h"



#define DEFAULT_DB   [AlivcPlayerVideoDBManager shareManager]

@interface AlivcPlayerVideoDBManager : NSObject

+ (instancetype)shareManager;

/*********** 观看历史记录部分 *********/

- (void)addHistoryTVModel:(AlivcPlayerVideoDBModel *)model;

- (BOOL)hasHistoryTVModelFromvideoId:(NSString *)videoId userId:(NSString *)userId;

- (AlivcPlayerVideoDBModel *)getHistoryTVModelFromvideoId:(NSString *)videoId userId:(NSString *)userId;

- (void)deleteAllHistory:(NSString *)userId ;

- (NSArray *)historyTVModelArray:(NSString *)userId ;

- (void)deleteHistoryTimeOut;

@end

