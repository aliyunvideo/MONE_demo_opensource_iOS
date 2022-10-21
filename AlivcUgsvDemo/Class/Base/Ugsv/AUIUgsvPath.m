//
//  AUIUgsvPath.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import "AUIUgsvPath.h"

@implementation AUIUgsvPath


+ (NSString *)cacheDir {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    cacheDir = [cacheDir stringByAppendingPathComponent:@"AUIUgsvCache"];
    return cacheDir;
}

+ (void)clearCache {
    NSString *cacheDir = [self cacheDir];
    if ([[NSFileManager defaultManager ] fileExistsAtPath:cacheDir]) {
        [[NSFileManager defaultManager ] removeItemAtPath:cacheDir error:nil];
    }
}

+ (BOOL)makeDirExist:(NSString *)dir {
    BOOL isDir = NO;
    NSFileManager *fileMgr = NSFileManager.defaultManager;
    if (![fileMgr fileExistsAtPath:dir isDirectory:&isDir] || !isDir) {
        return [fileMgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

+ (NSString *)cacheFile:(NSString *)fileName {
    NSString *dir = [self cacheDir];
    [self makeDirExist:dir];
    return [dir stringByAppendingPathComponent:fileName];
}

+ (NSString *)documentDir {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)documentPathWithPath:(NSString *)dirPath {
    return [[self documentDir] stringByAppendingPathComponent:dirPath];
}

+ (NSString *)rootDir {
    return [self documentPathWithPath:@"AUIUgsvCache"];
}

+ (NSString *)editorDir {
    return [[self rootDir] stringByAppendingPathComponent:@"editor"];
}

+ (NSString *)exportDir {
    return [[self rootDir] stringByAppendingPathComponent:@"export"];
}

+ (NSString *)musicDir {
    return [[self rootDir] stringByAppendingPathComponent:@"music"];
}

+ (NSString *)musicFile:(NSString *)fileName {
    NSString *dir = self.musicDir;
    [self makeDirExist:dir];
    return [dir stringByAppendingPathComponent:fileName];
}

+ (NSString *)editorTaskPath:(BOOL)makeDirIfNeed {
    NSString *path = [[self editorDir] stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    if (makeDirIfNeed) {
        [self makeDirExist:path];
    }
    return path;
}

+ (NSString *)exportFilePath:(NSString *)fileName {
    NSString *dir = [self exportDir];
    [self makeDirExist:dir];
    if (fileName.length == 0) {
        fileName = [[NSUUID UUID].UUIDString stringByAppendingString:@".mp4"];
    }
    NSString *path = [dir stringByAppendingPathComponent:fileName];
    return path;
}

@end
