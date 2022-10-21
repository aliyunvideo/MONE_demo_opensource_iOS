//
//  AUIResourceManager.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import <Foundation/Foundation.h>
#import "AUIResourceModel.h"

NS_ASSUME_NONNULL_BEGIN

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

- (void)fetchFontFlowerDataWithCallBack:(ResourceCallBack)callBack;

- (void)fetchFaceStickerDataWithCallback:(ResourceCallBack)callBack;

- (void)fetchFilterDataWithCallback:(ResourceCallBack)callBack;

- (void)fetchAnimationEffectsDataWithCallback:(ResourceCallBack)callBack;

- (void)fetchCaptionStyleTempleteWithCallback:(ResourceCallBack)callBack;

- (void)fetchCaptionFontWithCallback:(ResourceCallBack)callBack;


- (void)fetchMusicDataWithCallback:(ResourceCallBack)callBack;
- (NSString *)getLocalMusicWithId:(NSString *)musicId;
- (void) downloadMusicWithId:(NSString *)musicId
                  onProgress:(void(^)(float progress))onProgress
                   onSuccess:(void(^)(NSString *localPath))onSuccess
                      onFail:(void(^)(NSError *errMsg))onFail;

@end

NS_ASSUME_NONNULL_END
