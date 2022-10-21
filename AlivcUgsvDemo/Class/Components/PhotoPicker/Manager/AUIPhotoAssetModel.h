//
//  AVPhotoAssetModel.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/23.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AUIPhotoAssetType) {
    AUIPhotoAssetTypePhoto = 0,
    AUIPhotoAssetTypeVideo,
};

@interface AUIPhotoAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) AUIPhotoAssetType type;
@property (nonatomic, assign) NSTimeInterval assetDuration;
@property (nonatomic, strong) UIImage *thumbnailImage;

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(AUIPhotoAssetType)type;

@end


@interface AUIPhotoAlbumModel : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger assetsCount;
@property (nonatomic, strong) PHFetchResult *fetchResult;

- (instancetype)initWithFetchResult:(PHFetchResult *)result albumName:(NSString *)albumName;

@end


NS_ASSUME_NONNULL_END

