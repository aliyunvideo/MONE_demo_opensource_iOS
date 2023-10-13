//
//  AVPhotoLibraryManager.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/23.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "AUIPhotoAssetModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface AUIPhotoLibraryManager : NSObject

// 相册授权
+ (BOOL)authorizationStatusAuthorized;
+ (void)requestAuthorization:(void (^)(BOOL authorization))completion;

// 获取相机胶卷相册
+ (void)getCameraRollAlbumAllowPickingVideo:(BOOL)allowPickingVideo
                          allowPickingImage:(BOOL)allowPickingImage
            sortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate
                              durationRange:(CMTimeRange)durationRange
                                 completion:(void (^)(AUIPhotoAlbumModel *model))completion;


// 获得相册列表
+ (void)getAllAlbumsAllowPickingVideo:(BOOL)allowPickingVideo
                    allowPickingImage:(BOOL)allowPickingImage
      sortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate
                        durationRange:(CMTimeRange)durationRange
                           completion:(void (^)(NSArray<AUIPhotoAlbumModel *> * _Nonnull models))completion;
// 获取相册封面
+ (void)getPostImageWithAlbumModel:(AUIPhotoAlbumModel *)model
   sortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate
                        completion:(void (^)(UIImage *postImage))completion;


// 获得Asset列表
+ (void)getAssetsFromFetchResult:(PHFetchResult *)fetchResult
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<AUIPhotoAssetModel *> *models))completion;


// 获得指定大小图片
+ (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
+ (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion
                      progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                 networkAccessAllowed:(BOOL)networkAccessAllowed;

// 获得原图数据
+ (PHImageRequestID)getOriginalPhotoDataWithAsset:(PHAsset *)asset
                                       completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info, BOOL isDegraded))completion;
+ (PHImageRequestID)getOriginalPhotoDataWithAsset:(PHAsset *)asset
                                  progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                                       completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info, BOOL isDegraded))completion;


// 获取视频
+ (void)getVideoWithAsset:(PHAsset *)asset
          progressHandler:(nullable void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
               completion:(void (^)(AVAsset *avAsset, NSDictionary *info))completion;

// 获取视频地址
+ (void)getVideoPathWithAsset:(PHAsset *)asset
                withOutputDir:(NSString *)outputDir
                   completion:(void (^)(NSString *filePath, NSError *error))completion;
// 获取图片地址，会导出到OutputDir中
+ (void)getPhotoPathWithAsset:(PHAsset *)asset
                withOutputDir:(NSString *)outputDir
                   completion:(void (^)(NSString *filePath, NSError *error))completion;

// 保存视频到相册
+ (void)saveVideoWithUrl:(NSURL *)url
                location:(nullable CLLocation *)location
              completion:(void (^)(PHAsset *asset, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
