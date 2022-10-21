//
//  AUIPlayerWatchPointService.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/29.
//

#import "AUIPlayerWatchPointService.h"

@implementation AlivcPlayerWatchPointModel

@end

@interface AUIPlayerWatchPointService ()
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation AUIPlayerWatchPointService

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    _dataList = [NSMutableArray array];
    
    {
        AlivcPlayerWatchPointModel *model = [AlivcPlayerWatchPointModel new];
        model.ts = 5 * 1000;
        model.text = @"围绕在掌控的银河系边远星带_1";
        [self.dataList addObject:model];
    }
    
    {
        AlivcPlayerWatchPointModel *model = [AlivcPlayerWatchPointModel new];
        model.ts = 52 * 1000;
        model.text = @"围绕在掌控的银河系边远星带_2";
        [self.dataList addObject:model];
    }
    
    {
        AlivcPlayerWatchPointModel *model = [AlivcPlayerWatchPointModel new];
        model.ts = 105 * 1000;
        model.text = @"围绕在掌控的银河系边远星带_3";
        [self.dataList addObject:model];
    }
    
    {
        AlivcPlayerWatchPointModel *model = [AlivcPlayerWatchPointModel new];
        model.ts = 221 * 1000;
        model.text = @"围绕在掌控的银河系边远星带_4";
        [self.dataList addObject:model];
    }
    
    {
        AlivcPlayerWatchPointModel *model = [AlivcPlayerWatchPointModel new];
        model.ts = 587 * 1000;
        model.text = @"围绕在掌控的银河系边远星带_5";
        [self.dataList addObject:model];
    }
}


- (NSArray<AlivcPlayerWatchPointModel *> *)getWatchPoints
{
    return self.dataList.copy;
}
@end
