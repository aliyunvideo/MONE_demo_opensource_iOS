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

+ (void)startVideoCrop:(NSString *)videoFilePath
             startTime:(NSTimeInterval)startTime
               endTime:(NSTimeInterval)endTime
              cropRect:(CGRect)cropRect
                 param:(AUIVideoOutputParam *)param
              progress:(void (^)(float progress))progress
             completed:(void (^)(NSError * _Nullable error, NSString *_Nullable outputPath))completed;

+ (void)startPhotoCrop:(NSString *)imageFilePath
              cropRect:(CGRect)cropRect
            outputSize:(CGSize)outputSize
             completed:(void (^)(NSError * _Nullable error, NSString *_Nullable outputPath))completed;

+ (void)cropOnCutter:(AUIVideoCutterParam *)param cancelBlock:(void (^ _Nullable)(void))cancelBlock completedBlock:(void (^)(NSString *outputPath))completedBlock;

@end

NS_ASSUME_NONNULL_END
