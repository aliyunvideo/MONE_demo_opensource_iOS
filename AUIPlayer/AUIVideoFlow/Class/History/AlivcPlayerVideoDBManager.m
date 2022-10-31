//
//  AlivcPlayerVideoDBManager.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcPlayerVideoDBManager.h"
#import <FMDB/FMDB.h>
#import <UIKit/UIKit.h>

@interface AlivcPlayerVideoDBManager ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) FMDatabase *database;

@end

@implementation AlivcPlayerVideoDBManager

+ (instancetype)shareManager {
    static AlivcPlayerVideoDBManager *dbManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbManager = [[AlivcPlayerVideoDBManager alloc]init];
    });
    return dbManager;
}

- (instancetype)init {
    if (self = [super init]) {
        
       
        NSString *homePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSLog(@"%@",homePath);
        NSString *dbPath = [homePath stringByAppendingPathComponent:@"AlivcPlayerVideoDBManager_SQL.sqlite"];
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            self.database = db;
            if ([db open]){
                NSLog(@"数据库创建成功");
            }else {
                NSLog(@"数据库创建失败！");
            }
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS VideoHistoryTable (IDInteger INTEGER primary key autoincrement, videoId TEXT, userId TEXT, watchTime TEXT, modifyTime INTEGER, vaildTime INTEGER)"];
        }];
        
    }
    return self;
}

/*********** 观看历史记录部分 *********/

- (void)addHistoryTVModel:(AlivcPlayerVideoDBModel *)model {
    NSDate *datenow = [NSDate date];
    long modifyTime = (long)[datenow timeIntervalSince1970];
    if ([self hasHistoryTVModelFromvideoId:model.videoId userId:model.userId]) {
        //存在这个model，进行跟新
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            NSString *sqlStr = [NSString stringWithFormat:@"UPDATE VideoHistoryTable SET watchTime = '%@',modifyTime = '%ld',vaildTime = '%lld' WHERE videoId = '%@' AND userId = '%@'",model.watchTime,modifyTime,model.vaildTime,model.videoId,model.userId];
            [db executeUpdate:sqlStr];
        }];
    }else {
        //没有这个model，新添加
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO VideoHistoryTable (videoId ,userId,watchTime,modifyTime,vaildTime) VALUES('%@','%@','%@','%ld','%lld')",model.videoId,model.userId,model.watchTime,modifyTime,model.vaildTime];
        [self.database executeUpdate:sqlStr];
    }
    model.ts = modifyTime;
}

- (BOOL)hasHistoryTVModelFromvideoId:(NSString *)videoId userId:(NSString *)userId
{
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM VideoHistoryTable WHERE videoId = '%@' AND userId = '%@'",videoId,userId];
    FMResultSet * set = [self.database executeQuery:sqlStr];
    while ([set next]) {
        [set close];
        return YES;
    }
    return NO;
}

- (AlivcPlayerVideoDBModel *)getHistoryTVModelFromvideoId:(NSString *)videoId userId:(NSString *)userId
{
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM VideoHistoryTable WHERE videoId = '%@' AND userId = '%@'",videoId,userId];
    FMResultSet * set = [self.database executeQuery:sqlStr];
    
    NSDate *datenow = [NSDate date];
    long timeNow = (long)[datenow timeIntervalSince1970];
    
    AlivcPlayerVideoDBModel *model = nil;
    while ([set next]) {
        model = [[AlivcPlayerVideoDBModel alloc] init];
        model.videoId = [set stringForColumn:@"videoId"];
        model.userId = [set stringForColumn:@"userId"];
        model.watchTime = [set stringForColumn:@"watchTime"];
        model.ts = [set longForColumn:@"modifyTime"];
        model.vaildTime = [set longForColumn:@"vaildTime"];
        if (timeNow - model.ts >=  model.vaildTime) {
            model = nil;
        }
    }
    [set close];

    return model;
}

- (void)deleteAllHistory:(NSString *)userId {
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM VideoHistoryTable WHERE userId = '%@'",userId];
    }];
}

- (NSArray *)historyTVModelArray:(NSString *)userId {
    NSMutableArray *backArray = [NSMutableArray array];
    FMResultSet * set = [self.database executeQuery:@"SELECT * FROM VideoHistoryTable Order By modifyTime Desc WHERE userId = '%@'",userId];
    
    
    NSDate *datenow = [NSDate date];
    long timeNow = (long)[datenow timeIntervalSince1970];
    
    while ([set next]) {
        AlivcPlayerVideoDBModel *model = [[AlivcPlayerVideoDBModel alloc] init];
        model.videoId = [set stringForColumn:@"videoId"];
        model.userId = [set stringForColumn:@"userId"];
        model.watchTime = [set stringForColumn:@"watchTime"];
        model.ts = [set longForColumn:@"ts"];
        model.vaildTime = [set longForColumn:@"vaildTime"];
        
        if (timeNow - model.ts <  model.vaildTime) {
            [backArray addObject:model];
        }
    }
    [set close];
    return backArray.copy;
}

- (void)deleteHistoryTimeOut
{
    NSDate *datenow = [NSDate date];
    long timeNow = (long)[datenow timeIntervalSince1970];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
       bool ret = [db executeUpdate:@"DELETE FROM VideoHistoryTable WHERE modifyTime <= '%ld' - vaildTime",timeNow];
        NSLog(@"ret==%d",ret);
    }];
    
}

@end
