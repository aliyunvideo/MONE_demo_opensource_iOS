//
//  AUIShortEpisodeData.m
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/17.
//

#import "AUIShortEpisodeData.h"
#import <AFNetworking/AFNetworking.h>
#import "AUIFoundation.h"

@implementation AUIShortEpisodeData

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.eid = [dict av_stringValueForKey:@"id"];
        self.title = [dict av_stringValueForKey:@"title"];
        NSMutableArray *list = [NSMutableArray array];
        NSArray<NSDictionary *> *datas = [dict av_dictArrayValueForKey:@"list"];
        [datas enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIVideoInfo *info = [[AUIVideoInfo alloc] initWithDict:obj];
            info.uid = [NSString av_randomString];
            [list addObject:info];
        }];
        self.list = list;
    }
    return self;
}

@end


@implementation AUIShortEpisodeDataManager

+ (void)fetchData:(NSString *)eid completed:(void (^)(AUIShortEpisodeData *, NSError *))completed {
    // TODO: 请求服务端返回短剧数据，此次是仅模拟，有需要请自身实现
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] init];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://alivc-demo-cms.alicdn.com/versionProduct/resources/player/aui_episode.json"]] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (error) {
            NSLog(@"下载失败：%@", error);
            if (completed) {
                completed(nil, error);
            }
        }
        else {
            NSLog(@"下载成功：%@", filePath);
            NSData *jsonData = [NSData dataWithContentsOfURL:filePath];
            if (jsonData) {
                NSError *jsonError = nil;
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    NSLog(@"解析JSON失败：%@", jsonError);
                    if (completed) {
                        completed(nil, jsonError);
                    }
                }
                else {
                    NSLog(@"JSON数据：%@", jsonDictionary);
                    AUIShortEpisodeData *episode = [[AUIShortEpisodeData alloc] initWithDict:jsonDictionary];
                    if (completed) {
                        completed(episode, nil);
                    }
                }
            }
            else {
                NSLog(@"读取JSON文件失败");
                if (completed) {
                    completed(nil, [NSError errorWithDomain:@"" code:-1 userInfo:nil]);
                }
            }
        }
    }];
    [downloadTask resume];
}

@end
