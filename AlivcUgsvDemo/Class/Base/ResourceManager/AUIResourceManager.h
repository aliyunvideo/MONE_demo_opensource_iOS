//
//  AUIResourceManager.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import <Foundation/Foundation.h>
#import "AUIResourceModel.h"

NS_ASSUME_NONNULL_BEGIN

// ⚠️警告
// ⚠️本产品内置的字体资源，需要使用请自身确认版权问题，如不可商用或无版权，请勿使用
// ⚠️本产品内置的音乐资源及下载地址，仅用于官方demo演示使用，请勿使用。如需使用请自身购买版权
// ⚠️本产品内置的所有素材为官方demo演示使用，无法达到商业化使用程度，如有问题，请联系官方。

typedef NS_ENUM(NSUInteger, AUIResourceType) {
    AUIResourceTypeSticker,
    AUIResourceTypeFaceSticker,
    AUIResourceTypeBubble,
    AUIResourceTypeFontFlower,
    AUIResourceTypeCaptionFont,
    AUIResourceTypeCaptionStyleTemplete,
    AUIResourceTypeFilter,
    AUIResourceTypeAnimationEffects,
    AUIResourceTypeMusic,
};

typedef void (^ResourceCallBack)(NSError * _Nullable error, NSArray * _Nullable data);
typedef void (^SearchResourceCallback)(NSError * _Nullable error, AUIResourceModel * _Nullable data);

@interface AUIResourceManager : NSObject

+ (AUIResourceManager *)manager;

- (void)fetchDataWithType:(AUIResourceType)type callback:(ResourceCallBack)callback;
- (void)findDataWithType:(AUIResourceType)type path:(NSString *)path callback:(SearchResourceCallback)callback;

- (void)fetchStickerDataWithCallBack:(ResourceCallBack)callBack;

- (void)fetchBubbleDataWithCallBack:(ResourceCallBack)callBack;

// ⚠️本产品内置的字体资源，需要使用请自身确认版权问题，如不可商用或无版权，请勿使用
- (void)fetchFontFlowerDataWithCallBack:(ResourceCallBack)callBack;

- (void)fetchFaceStickerDataWithCallback:(ResourceCallBack)callBack;

- (void)fetchFilterDataWithCallback:(ResourceCallBack)callBack;

- (void)fetchAnimationEffectsDataWithCallback:(ResourceCallBack)callBack;

- (void)fetchCaptionStyleTempleteWithCallback:(ResourceCallBack)callBack;

// ⚠️本产品内置的字体资源，需要使用请自身确认版权问题，如不可商用或无版权，请勿使用
- (void)fetchCaptionFontWithCallback:(ResourceCallBack)callBack;

// ⚠️本产品内置的音乐资源及下载地址，仅用于官方demo演示使用，请勿使用。如需使用请自身购买版权
- (void)fetchMusicDataWithCallback:(ResourceCallBack)callBack;
- (NSString *)getLocalMusicWithId:(NSString *)musicId;
- (void) downloadMusicWithId:(NSString *)musicId
                  onProgress:(void(^)(float progress))onProgress
                   onSuccess:(void(^)(NSString *localPath))onSuccess
                      onFail:(void(^)(NSError *errMsg))onFail;

@end

NS_ASSUME_NONNULL_END
