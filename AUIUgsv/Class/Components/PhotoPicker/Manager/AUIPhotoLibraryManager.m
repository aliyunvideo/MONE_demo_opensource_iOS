//
//  AVPhotoLibraryManager.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIPhotoLibraryManager.h"
#import "AUIUgsvMacro.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface AUIPhotoLibraryManager ()

@end


@implementation AUIPhotoLibraryManager

#pragma mark --- 权限控制

+ (BOOL)authorizationStatusAuthorized {
    return [self authorizationStatus] == 3;
}

+ (NSInteger)authorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

+ (void)requestAuthorization:(void (^)(BOOL authorization))completion {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    if (completion) {
                        completion(YES);
                    }
                    break;
                
                case PHAuthorizationStatusDenied:
                    if (completion) {
                        completion(NO);
                    }
                    [self openSetting:AUIUgsvGetString(@"需要打开权限才能访问相册")];
                    break;
                
                case PHAuthorizationStatusRestricted:
                    if (completion) {
                        completion(NO);
                    }
                    break;
               
                default:
                    break;
            }
        });
    }];
}

+ (void)openSetting:(NSString *)message {
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:AUIFoundationLocalizedString(@"Cancel") style:UIAlertActionStyleDestructive handler:nil];
    UIAlertAction *action2 =[UIAlertAction actionWithTitle:AUIFoundationLocalizedString(@"Setting") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    [vc presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --- 获取相册 & asset

+ (AUIPhotoAssetModel *)assetModelWithAsset:(PHAsset *)phAsset
                         allowPickingVideo:(BOOL)allowPickingVideo
                         allowPickingImage:(BOOL)allowPickingImage {

    if (phAsset.mediaType == PHAssetMediaTypeVideo){
        if (allowPickingVideo) {
            AUIPhotoAssetModel *model = [AUIPhotoAssetModel modelWithAsset:phAsset type:AUIPhotoAssetTypeVideo];
            return model;
        }
    }
    
    if (phAsset.mediaType == PHAssetMediaTypeImage){
        if (allowPickingImage) {
            AUIPhotoAssetModel *model = [AUIPhotoAssetModel modelWithAsset:phAsset type:AUIPhotoAssetTypePhoto];
            return model;
        }
    }
    return nil;
}

+ (NSPredicate *)configurePredicateWithAllowImage:(BOOL)image
                                       allowVideo:(BOOL)video
                                            range:(CMTimeRange)range {
    NSPredicate *predicate;
    
    NSString *imageFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    NSString *videoFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    if (!CMTimeRangeEqual(range, kCMTimeRangeZero)) {
        NSString *rangeForamt = [NSString stringWithFormat:@" && duration >= %f && duration <= %f", CMTimeGetSeconds(range.start), CMTimeGetSeconds(CMTimeRangeGetEnd(range))];
        videoFormat = [videoFormat stringByAppendingString:rangeForamt];
    }
    if (image && !video) {
        predicate = [NSPredicate predicateWithFormat:imageFormat];
    } else if (video && !image) {
        predicate = [NSPredicate predicateWithFormat:videoFormat];
    } else if (video && image) {
        NSString *imageAndVideo = [NSString stringWithFormat:@"%@ || (%@)", videoFormat, imageFormat];
        predicate = [NSPredicate predicateWithFormat:imageAndVideo];
    }
    return predicate;
}

+ (BOOL)isCameraRollAlbum:(PHAssetCollection *)metadata {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 ~ 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
    } else {
        return ((PHAssetCollection *)metadata).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    }
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (void)getCameraRollAlbumAllowPickingVideo:(BOOL)allowPickingVideo
                          allowPickingImage:(BOOL)allowPickingImage
            sortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate
                              durationRange:(CMTimeRange)durationRange
                                 completion:(void (^)(AUIPhotoAlbumModel *model))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AUIPhotoAlbumModel *model;
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.predicate = [self configurePredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo range:durationRange];
        if (!sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:sortAscendingByModificationDate]];
        }
        
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            // 过滤空相册
            if (collection.estimatedAssetCount <= 0) continue;
            if ([self isCameraRollAlbum:collection]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                model = [[AUIPhotoAlbumModel alloc] initWithFetchResult:fetchResult albumName:collection.localizedTitle];
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(model);
            }
        });
    });
}

+ (void)getAllAlbumsAllowPickingVideo:(BOOL)allowPickingVideo
                    allowPickingImage:(BOOL)allowPickingImage
      sortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate
                        durationRange:(CMTimeRange)durationRange
                           completion:(void (^)(NSArray<AUIPhotoAlbumModel *> * _Nonnull models))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *albumArr = [NSMutableArray array];
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.predicate = [self configurePredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo range:durationRange];
        
        if (!sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:sortAscendingByModificationDate]];
        }
        
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        NSArray *allAlbums = @[myPhotoStreamAlbum, smartAlbums, topLevelUserCollections, syncedAlbums, sharedAlbums];
        for (PHFetchResult *fetchResult in allAlbums) {
            for (PHAssetCollection *collection in fetchResult) {
                
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                
                // 过滤空相册
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                if (fetchResult.count < 1) continue;
                
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
                if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
                
                if ([self isCameraRollAlbum:collection]) {
                    AUIPhotoAlbumModel *model = [[AUIPhotoAlbumModel alloc] initWithFetchResult:fetchResult albumName:collection.localizedTitle];
                    [albumArr insertObject:model atIndex:0];
                }
                else {
                    AUIPhotoAlbumModel *model = [[AUIPhotoAlbumModel alloc] initWithFetchResult:fetchResult albumName:collection.localizedTitle];
                    [albumArr addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(albumArr);
            }
        });
    });
}

// 相册封面
+ (void)getPostImageWithAlbumModel:(AUIPhotoAlbumModel *)model
   sortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate
                        completion:(void (^)(UIImage *))completion {
    PHAsset *asset = [model.fetchResult lastObject];
    if (!sortAscendingByModificationDate) {
        asset = [model.fetchResult firstObject];
    }
    if (!asset) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    [self getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo);
        }
    }];
}

+ (void)getAssetsFromFetchResult:(PHFetchResult *)fetchResult
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<AUIPhotoAssetModel *> *models))completion {
    NSMutableArray *photoArr = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AUIPhotoAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completion) {
        completion(photoArr);
    }
}

+ (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

+ (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = photoWidth * 2.0;
    // 超宽图片
    if (aspectRatio > 1.8) {
        pixelWidth = pixelWidth * aspectRatio;
    }
    // 超高图片
    if (aspectRatio < 0.2) {
        pixelWidth = pixelWidth * 0.5;
    }
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    // 修复获取图片时出现的瞬间内存过高问题
    // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    int32_t imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
        BOOL cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
        if (!cancelled && result) {
            result = [self fixOrientation:result];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            });
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler) {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                if (!resultImage && result) {
                    resultImage = result;
                }
                resultImage = [self fixOrientation:resultImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(resultImage,info,NO);
                    }
                });
            }];
        }
    }];
    return imageRequestID;
}

+ (PHImageRequestID)getOriginalPhotoDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info, BOOL isDegraded))completion {
    return [self getOriginalPhotoDataWithAsset:asset progressHandler:nil completion:completion];
}

+ (PHImageRequestID)getOriginalPhotoDataWithAsset:(PHAsset *)asset progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info, BOOL isDegraded))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
        // if version isn't PHImageRequestOptionsVersionOriginal, the gif may cann't play
        option.version = PHImageRequestOptionsVersionOriginal;
    }
    [option setProgressHandler:progressHandler];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    return [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        BOOL cancelled = [[info objectForKey:PHImageCancelledKey] boolValue];
        if (!cancelled && imageData) {
            if (completion) completion(imageData, dataUTI, orientation, info, NO);
        }
    }];
}

+ (void)getVideoWithAsset:(PHAsset *)asset
          progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
               completion:(void (^)(AVAsset * avAsset, NSDictionary * info))completion {
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.progressHandler = progressHandler;
    
    PHAsset *phAsset = (PHAsset *)asset;
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if (completion) {
            completion(asset, info);
        }
    }];
}

+ (void)getVideoPathWithAsset:(PHAsset *)asset withOutputDir:(NSString *)outputDir completion:(void (^)(NSString * filePath, NSError * error))completion {
    
    [self getVideoWithAsset:asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil, error);
                }
            });
            *stop = YES;
        }
    } completion:^(AVAsset * _Nonnull avAsset, NSDictionary * _Nonnull info) {
        if(([avAsset isKindOfClass:[AVComposition class]] && ((AVComposition *)avAsset).tracks.count == 2)){
            //slow motion videos. See Here: https://overflow.buffer.com/2016/02/29/slow-motion-video-ios/
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:outputDir]) {
                [fileManager createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *filePath = [outputDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", [NSUUID UUID].UUIDString]];
            NSURL *url = [NSURL fileURLWithPath:filePath];
            //Begin slow mo video export
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
            exporter.outputURL = url;
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            __weak typeof(AVAssetExportSession *) weakExporter = exporter;
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                __strong typeof(AVAssetExportSession *) strongExporter = weakExporter;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (exporter.status == AVAssetExportSessionStatusCompleted) {
                        if (completion) {
                            completion(filePath, nil);
                        }
                    }
                    else {
                        if (completion) {
                            completion(nil, strongExporter.error);
                        }
                    }
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                    NSString *filePath = urlAsset.URL.absoluteString;
                    if ([filePath hasPrefix:@"file://"]) {
                        filePath = [filePath substringFromIndex:[@"file://" length]];
                    }
                    completion(filePath, nil);
                }
            });
        }
    }];
}


+ (void)getPhotoPathWithAsset:(PHAsset *)asset withOutputDir:(NSString *)outputDir completion:(void (^)(NSString *filePath, NSError *error))completion {
    [self getOriginalPhotoDataWithAsset:asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil, error);
                }
            });
            *stop = YES;
        }
    } completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info, BOOL isDegraded) {
        if (isDegraded) {
            return;
        }
        NSString *ext = @".jpeg";
        if (orientation != UIImageOrientationUp) {
            UIImage *finalImage = [UIImage imageWithData:imageData];
            UIGraphicsBeginImageContextWithOptions(finalImage.size, NO, finalImage.scale);
            [finalImage drawInRect:(CGRect){0, 0, finalImage.size}];
            UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            imageData = UIImageJPEGRepresentation(normalizedImage, 1);
        }
        else {
            ext = [self extensionForImageData:imageData];
            if (ext.length == 0) {
                UIImage *finalImage = [UIImage imageWithData:imageData];
                imageData = UIImageJPEGRepresentation(finalImage, 1);
                ext = @".jpeg";
            }
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:outputDir]) {
            [fileManager createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [outputDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [NSUUID UUID].UUIDString, ext]];
        if ([imageData writeToFile:filePath atomically:YES]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(filePath, nil);
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil, [NSError errorWithDomain:@"" code:-1 userInfo:nil]);
                }
            });
        }
    }];
}

+ (NSString *)extensionForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
    case 0xFF:
        return @".jpeg";
    case 0x89:
        return @".png";
//    case 0x47:
//        return @".gif";
//    case 0x49:
//    case 0x4D:
//        return @".tiff";
    }
    return nil;
}


+ (void)saveVideoWithUrl:(NSURL *)url location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion {
    __block NSString *localIdentifier = nil;
    [AUIPhotoLibraryManager requestAuthorization:^(BOOL authorization) {
        if (!authorization) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:@"com.alivc.ugsv.demo" code:-1 userInfo:@{
                    NSLocalizedDescriptionKey: @"no authorization"
                }];
                completion(nil, error);
            }
            return;
        }
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
            if (location) {
                request.location = location;
            }
            request.creationDate = [NSDate date];
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success && completion && localIdentifier) {
                    [self fetchAssetByIocalIdentifier:localIdentifier retryCount:10 completion:completion];
                } else {
                    if (error) {
                        NSLog(@"保存视频出错:%@",error.localizedDescription);
                    }
                    if (completion) {
                        completion(nil, error);
                    }
                }
            });
        }];
    }];
}

+ (void)fetchAssetByIocalIdentifier:(NSString *)localIdentifier retryCount:(NSInteger)retryCount completion:(void (^)(PHAsset *asset, NSError *error))completion {
    PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
    if (asset || retryCount <= 0) {
        if (completion) {
            completion(asset, nil);
        }
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchAssetByIocalIdentifier:localIdentifier retryCount:retryCount - 1 completion:completion];
    });
}


@end
