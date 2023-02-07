//
//  AUIPhotoPicker.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#import "AUIFoundation.h"
#import "AUIPhotoLibraryManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPhotoPickerInputItem : NSObject

@property (nonatomic, assign) BOOL allowPickingImage;
@property (nonatomic, assign) BOOL allowPickingVideo;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, assign) BOOL filterByDuration; //YES则为不限时长
@property (nonatomic, weak) id extend;

@end

@interface AUIPhotoPickerResult : NSObject

@property (nonatomic, copy, nullable, readonly) NSString *filePath;
@property (nonatomic, copy, nullable, readonly) AUIPhotoAssetModel *model;
@property (nonatomic, strong, nullable, readonly) AUIPhotoPickerInputItem *inputItem;

@end

@interface AUIPhotoPicker : AVBaseCollectionViewController

- (instancetype)initWithMaxPickingCount:(NSUInteger)maxPickingCount  // 0则为不限个数
                  withAllowPickingImage:(BOOL)allowPickingImage
                  withAllowPickingVideo:(BOOL)allowPickingVideo
                          withTimeRange:(CMTimeRange)timeRange; //kCMTimeRangeZero则为不限时长

- (instancetype)initWithInputItems:(NSArray<AUIPhotoPickerInputItem *> *)items;

- (void)onSelectionCompleted:(void(^)(AUIPhotoPicker *sender, NSArray<AUIPhotoAssetModel *> *models))completedBlock;
- (void)onSelectionCompleted:(void(^)(AUIPhotoPicker *sender, NSArray<AUIPhotoPickerResult *> *results))completedBlock withOutputDir:(NSString *)outputDir;


@end

NS_ASSUME_NONNULL_END
