//
//  AVPhotoAssetModel.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIPhotoAssetModel.h"
#import "AVStringFormat.h"

@implementation AUIPhotoAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(AUIPhotoAssetType)type {
    AUIPhotoAssetModel *model = [[AUIPhotoAssetModel alloc] init];
    model.asset = asset;
    model.type = type;
    model.assetDuration = type == AUIPhotoAssetTypeVideo ? asset.duration : self.photoDefaultDuration;
    return model;
}

static NSTimeInterval _photoDefaultDuration = 3.0;
+ (NSTimeInterval)photoDefaultDuration {
    return _photoDefaultDuration;
}

+ (void)setPhotoDefaultDuration:(NSTimeInterval)photoDefaultDuration {
    if (photoDefaultDuration < 0.1) {
        return;
    }
    _photoDefaultDuration = photoDefaultDuration;
}

@end


@implementation AUIPhotoAlbumModel

- (instancetype)initWithFetchResult:(PHFetchResult *)result albumName:(NSString *)albumName {
    self = [super init];
    if (self) {
        _fetchResult = result;
        _albumName = albumName;
        _assetsCount = result.count;
    }
    return self;
}

@end
