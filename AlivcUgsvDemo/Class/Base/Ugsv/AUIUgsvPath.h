//
//  AUIUgsvPath.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIUgsvPath : NSObject

+ (NSString *)cacheDir;
+ (void)clearCache;
+ (NSString *)cacheFile:(NSString *)fileName;

+ (BOOL)makeDirExist:(NSString *)dir;

+ (NSString *)editorDir;
+ (NSString *)editorTaskPath:(BOOL)makeDirIfNeed;

+ (NSString *)musicDir;
+ (NSString *)musicFile:(NSString *)fileName;

+ (NSString *)exportDir;
+ (NSString *)exportFilePath:(nullable NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
