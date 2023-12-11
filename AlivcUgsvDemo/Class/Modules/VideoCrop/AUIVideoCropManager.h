//
//  AUIVideoCropManager.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/23.
//

#import <UIKit/UIKit.h>
#import "AUIVideoOutputParam.h"
#import "AUIVideoCutter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoCropManager : NSObject

// 无UI视频裁剪，包括画面大小、时间轴、编码等
+ (void)startVideoCrop:(NSString *)videoFilePath
             startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime
              cropRect:(CGRect)cropRect
                 param:(AUIVideoOutputParam *)param
              progress:(void (^)(float progress))progress
             completed:(void (^)(NSError * _Nullable error, NSString *_Nullable outputPath))completed;

// 无UI图片裁剪，画面裁剪
+ (void)startPhotoCrop:(NSString *)imageFilePath
              cropRect:(CGRect)cropRect
            outputSize:(CGSize)outputSize
             completed:(void (^)(NSError * _Nullable error, NSString *_Nullable outputPath))completed;

// 含UI交互式的裁剪
+ (void)cropOnCutter:(AUIVideoCutterParam *)param cancelBlock:(void (^ _Nullable)(void))cancelBlock completedBlock:(void (^)(NSString *outputPath))completedBlock;

@end

NS_ASSUME_NONNULL_END
