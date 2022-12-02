//
//  AUIResourceManager.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import "AUIResourceManager.h"
#import "AUIStickerModel.h"
#import "AUIFilterModel.h"
#import "AUIMusicModel.h"
#import "AUIUgsvPath.h"
#import <AFNetworking/AFNetworking.h>
#import "AUICaptionStyleTempleteModel.h"
#import "AUICaptionFontModel.h"


// ⚠️警告
// ⚠️本产品内置的字体资源，需要使用请自身确认版权问题，如不可商用或无版权，请勿使用
// ⚠️本产品内置的音乐资源及下载地址，仅用于官方demo演示使用，请勿使用。如需使用请自身购买版权
// ⚠️本产品内置的所有素材为官方demo演示使用，无法达到商业化使用程度，如有问题，请联系官方。


@interface AUIResourceManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *musicFileRecords; // musicId: fileName
@end

@implementation AUIResourceManager

+ (AUIResourceManager *)manager
{
    static AUIResourceManager *s_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_shared = [AUIResourceManager new];
    });
    return s_shared;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [AFHTTPSessionManager manager];
    return _sessionManager;
}

- (void)fetchStickerDataWithCallBack:(ResourceCallBack)callBack
{
    NSString *base_path =  [[NSBundle mainBundle] pathForResource:@"Sticker.bundle" ofType:nil];
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:base_path];
             
     BOOL isDir = NO;
     BOOL isExist = NO;
  
     NSMutableArray *temp = [NSMutableArray array];
     for (NSString *path in myDirectoryEnumerator.allObjects) {
      
         if ([path containsString:@"/"]) {
             continue;
         }
         isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", base_path, path] isDirectory:&isDir];
             if (isExist && isDir) {
                 NSLog(@"%@", path);    // 目录路径
                 NSString *dirName =  [path componentsSeparatedByString:@"-"].lastObject;
                 NSString *fullDir = [NSString stringWithFormat:@"%@/%@/%@", base_path, path, dirName];
                 AUIStickerModel *model = [[AUIStickerModel alloc] initWithResourcePath:fullDir];
                 [temp addObject:model];
         }
     }
    
    if (callBack) {
        callBack(nil, temp);
    }
}

- (void)fetchBubbleDataWithCallBack:(ResourceCallBack)callBack
{
    NSString *base_path =  [[NSBundle mainBundle] pathForResource:@"CaptionBub.bundle" ofType:nil];
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:base_path];
             
     BOOL isDir = NO;
     BOOL isExist = NO;
  
     NSMutableArray *temp = [NSMutableArray array];
     for (NSString *path in myDirectoryEnumerator.allObjects) {
      
         if ([path containsString:@"/"]) {
             continue;
         }
         isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", base_path, path] isDirectory:&isDir];
             if (isExist && isDir) {
                 NSLog(@"%@", path);    // 目录路径
                 NSString *dirName =  [path componentsSeparatedByString:@"-"].lastObject;
                 NSString *fullDir = [NSString stringWithFormat:@"%@/%@/%@", base_path, path, dirName];
                 AUIStickerModel *model = [[AUIStickerModel alloc] initWithResourcePath:fullDir];
                 [temp addObject:model];
         }
     }
    
    if (callBack) {
        callBack(nil, temp);
    }
  
}

// ⚠️本产品内置的字体资源，需要使用请自身确认版权问题，如不可商用或无版权，请勿使用
- (void)fetchFontFlowerDataWithCallBack:(ResourceCallBack)callBack
{
    NSString *base_path =  [[NSBundle mainBundle] pathForResource:@"FlowerFont.bundle" ofType:nil];
    base_path = [base_path stringByAppendingPathComponent:@"font_effect"];

     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:base_path];
      
    
     BOOL isDir = NO;
     BOOL isExist = NO;
    NSMutableArray *temp = [NSMutableArray array];
     for (NSString *path in myDirectoryEnumerator.allObjects) {
      
         if ([path containsString:@"/"]) {
             continue;
         }
         isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", base_path, path] isDirectory:&isDir];
             if (isExist && isDir) {
                 NSString *fullDir = [NSString stringWithFormat:@"%@/%@", base_path, path];

                 AUIStickerModel *model = [[AUIStickerModel alloc] initWithResourcePath:fullDir];
                 [temp addObject:model];
         }
     }
     
    if (callBack) {
        callBack(nil, temp);
    }
}

static NSArray<NSString *> * s_listSubDirectory(NSString *bundleName, NSError **error) {
    NSString *basePath = [NSBundle.mainBundle pathForResource:bundleName ofType:@"bundle"];
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSArray<NSString *> *subFiles = [fileManager contentsOfDirectoryAtPath:basePath error:error];
    if (*error) {
        return @[];
    }
    
    NSMutableArray *result = @[].mutableCopy;
    for (NSString *path in subFiles) {
        BOOL isDir = NO;
        NSString *fullPath = [basePath stringByAppendingPathComponent:path];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            [result addObject:fullPath];
        }
    }
    return result;
}

static void s_fetchData(NSString *bundleName, Class modelClass, ResourceCallBack callback) {
    NSError *error;
    NSArray<NSString *> *paths = s_listSubDirectory(bundleName, &error);
    if (error) {
        if (callback) {
            callback(error, @[]);
        }
        return;
    }
    
    NSMutableArray *result = @[].mutableCopy;
    for (NSString *path in paths) {
        id model = [[modelClass alloc] initWithResourcePath:path];
        [result addObject:model];
    }
    
    if (callback) {
        callback(nil, result);
    }
}


- (void)fetchFaceStickerDataWithCallback:(ResourceCallBack)callBack {
    s_fetchData(@"FaceSticker", AUIStickerModel.class, callBack);
}

- (void)fetchFilterDataWithCallback:(ResourceCallBack)callBack {
    s_fetchData(@"Filter", AUIFilterModel.class, callBack);
}

- (void)fetchAnimationEffectsDataWithCallback:(ResourceCallBack)callBack {
    s_fetchData(@"AnimationEffects", AUIFilterModel.class, callBack);
}


- (void)fetchCaptionStyleTempleteWithCallback:(ResourceCallBack)callBack
{
    s_fetchData(@"CaptionStyle", AUICaptionStyleTempleteModel.class, callBack);
}

// ⚠️本产品内置的字体资源，需要使用请自身确认版权问题，如不可商用或无版权，请勿使用
- (void)fetchCaptionFontWithCallback:(ResourceCallBack)callBack
{
    
    NSString *basePath = [NSBundle.mainBundle pathForResource:@"CaptionFont" ofType:@"bundle"];
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSError *error;
    NSArray<NSString *> *subFiles = [fileManager contentsOfDirectoryAtPath:basePath error:&error];
    if (error) {
        if (callBack) {
            callBack(error, nil);
        }
        return;
    }
    
    NSMutableArray *result = @[].mutableCopy;
    for (NSString *path in subFiles) {
        NSString *fullPath = [basePath stringByAppendingPathComponent:path];
        AUICaptionFontModel *model = [[AUICaptionFontModel alloc] initWithResourcePath:fullPath];
        [result addObject:model];
    }
    if (callBack) {
        callBack(nil, result);
    }
}

// MARK: - Music
// ⚠️本产品内置的音乐资源及下载地址，仅用于官方demo演示使用，请勿使用。如需使用请自身购买版权
- (void)fetchMusicDataWithCallback:(ResourceCallBack)callBack {
    NSString *dataPath = [NSBundle.mainBundle pathForResource:@"Music" ofType:@"bundle"];
    dataPath = [dataPath stringByAppendingPathComponent:@"data.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:dataPath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    NSArray *listData = data[@"data"][@"musicList"];
    NSMutableArray *result = @[].mutableCopy;
    for (NSDictionary *dict in listData) {
        [result addObject:[[AUIMusicModel alloc] initWithDict:dict]];
    }
    if (callBack) {
        callBack(nil, result);
    }
}

static NSString * s_musicFileRecordsPath() {
    return [AUIUgsvPath musicFile:@"MusicFileRecords.plist"];
}

- (NSMutableDictionary<NSString *, NSString *> *)musicFileRecords {
    if (_musicFileRecords) {
        return _musicFileRecords;
    }
    
    _musicFileRecords = [NSDictionary dictionaryWithContentsOfFile:s_musicFileRecordsPath()].mutableCopy;
    if (!_musicFileRecords) {
        _musicFileRecords = @{}.mutableCopy;
    }
    return _musicFileRecords;
}

- (void)saveMusicFileRecordWithId:(NSString *)musicId fileName:(NSString *)fileName {
    self.musicFileRecords[musicId] = fileName;
    [self.musicFileRecords writeToFile:s_musicFileRecordsPath() atomically:YES];
}

- (NSString *)getLocalMusicWithId:(NSString *)musicId {
    NSString *fileName = self.musicFileRecords[musicId];
    if (fileName.length == 0) {
        return nil;
    }
    NSString *path = [AUIUgsvPath musicFile:fileName];
    if (path && [NSFileManager.defaultManager fileExistsAtPath:path]) {
        return path;
    }
    return nil;
}

typedef void(^OnFail)(NSError *errMsg);
static void s_notifyFail(OnFail onFail, NSString *msg) {
    if (onFail) {
        NSError *err = [NSError errorWithDomain:@"com.alivc.ugsv.demo" code:-1 userInfo:@{
            NSLocalizedDescriptionKey: msg ?: @""
        }];
        onFail(err);
    }
}

static NSString * s_localMusicPath(NSString *musicId, NSString *urlString) {
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *fileExtension = [[url.path lastPathComponent] pathExtension];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", musicId, fileExtension];
    return [AUIUgsvPath musicFile:fileName];
}

- (void) downloadMusicWithId:(NSString *)musicId
                         url:(NSString *)url
            onProgress:(void(^)(float progress))onProgress
             onSuccess:(void(^)(NSString *localPath))onSuccess
                onFail:(void(^)(NSError *errMsg))onFail {
    NSString *toPath = s_localMusicPath(musicId, url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        if (onProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onProgress(downloadProgress.completedUnitCount * 1.0 / downloadProgress.totalUnitCount);
            });
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:toPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (onFail) {
                onFail(error);
            }
            return;
        }
        if (![NSFileManager.defaultManager fileExistsAtPath:toPath]) {
            s_notifyFail(onFail, @"download fail");
            return;
        }
        [self saveMusicFileRecordWithId:musicId fileName:toPath.lastPathComponent];
        if (onSuccess) {
            onSuccess(toPath);
        }
    }];
    [task resume];
}

- (void) downloadMusicWithId:(NSString *)musicId
                  onProgress:(void(^)(float progress))onProgress
                   onSuccess:(void(^)(NSString *localPath))onSuccess
                      onFail:(void(^)(NSError *errMsg))onFail {
    NSURLSessionDataTask *task = [self.sessionManager GET:@"https://alivc-demo.aliyuncs.com/music/getPlayPath" parameters:@{
        @"musicId": musicId
    } headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = responseObject;
        if (![result isKindOfClass:NSDictionary.class]) {
            s_notifyFail(onFail, @"getPlayPath fail");
            return;
        }
        result = result[@"data"];
        if (![result isKindOfClass:NSDictionary.class]) {
            s_notifyFail(onFail, @"getPlayPath error: response no data");
            return;
        }
        NSString *playPath = result[@"playPath"];
        if (![playPath isKindOfClass:NSString.class] || playPath.length == 0) {
            s_notifyFail(onFail, @"getPlayPath error: playPath is empty");
            return;
        }
        [self downloadMusicWithId:musicId url:playPath onProgress:onProgress onSuccess:onSuccess onFail:onFail];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (onFail) {
            onFail(error);
        }
    }];
    [task resume];
}

// MARK: - fetch data
- (void)fetchDataWithType:(AUIResourceType)type callback:(ResourceCallBack)callback {
    switch (type) {
        case AUIResourceTypeSticker:
            [self fetchStickerDataWithCallBack:callback];
            break;
        case AUIResourceTypeFaceSticker:
            [self fetchFaceStickerDataWithCallback:callback];
            break;
        case AUIResourceTypeBubble:
            [self fetchBubbleDataWithCallBack:callback];
            break;
        case AUIResourceTypeFontFlower:
            [self fetchFontFlowerDataWithCallBack:callback];
            break;
        case AUIResourceTypeCaptionFont:
            [self fetchCaptionFontWithCallback:callback];
            break;
        case AUIResourceTypeCaptionStyleTemplete:
            [self fetchCaptionStyleTempleteWithCallback:callback];
            break;
        case AUIResourceTypeFilter:
            [self fetchFilterDataWithCallback:callback];
            break;
        case AUIResourceTypeAnimationEffects:
            [self fetchAnimationEffectsDataWithCallback:callback];
            break;
        case AUIResourceTypeMusic:
            [self fetchMusicDataWithCallback:callback];
            break;
        default:
        {
            NSAssert(NO, @"Unknonw resource type");
            break;
        }
    }
}

- (void)findDataWithType:(AUIResourceType)type path:(NSString *)path callback:(SearchResourceCallback)callback {
    NSError *notFoundError = [NSError errorWithDomain:@"com.alivc.ugsv.demo" code:-1 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can not found resource(type:%d) with path(%@)", (int)type, path]
    }];
    if (path.length == 0) {
        if (callback) {
            callback(notFoundError, nil);
        }
        return;
    }
    
    NSAssert(type != AUIResourceTypeMusic, @"Music not support search by path");
    [self fetchDataWithType:type callback:^(NSError * _Nullable error, NSArray * _Nonnull data) {
        if (error) {
            if (callback) {
                callback(error, nil);
            }
            return;
        }
        for (AUIResourceModel *model in data) {
            if ([model.resourcePath isEqualToString:path]) {
                if (callback) {
                    callback(nil, model);
                }
                return;
            }
        }
        if (callback) {
            callback(notFoundError, nil);
        }
    }];
}

@end
