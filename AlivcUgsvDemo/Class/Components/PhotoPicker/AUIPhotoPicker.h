//
//  AUIPhotoPicker.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#import "AUIFoundation.h"
#import "AUIPhotoLibraryManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoPickerResult : NSObject

@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) AUIPhotoAssetModel *model;

@end

@interface AUIPhotoPicker : AVBaseCollectionViewController

- (instancetype)initWithMaxPickingCount:(NSUInteger)maxPickingCount  // 0则为不限个数
                  withAllowPickingImage:(BOOL)allowPickingImage
                  withAllowPickingVideo:(BOOL)allowPickingVideo
                          withTimeRange:(CMTimeRange)timeRange; //kCMTimeRangeZero则为不限时长

- (void)onSelectionCompleted:(void(^)(AUIPhotoPicker *sender, NSArray<AUIPhotoAssetModel *> *models))completedBlock;
- (void)onSelectionCompleted:(void(^)(AUIPhotoPicker *sender, NSArray<AUIPhotoPickerResult *> *results))completedBlock withOutputDir:(NSString *)outputDir;


@end

NS_ASSUME_NONNULL_END
