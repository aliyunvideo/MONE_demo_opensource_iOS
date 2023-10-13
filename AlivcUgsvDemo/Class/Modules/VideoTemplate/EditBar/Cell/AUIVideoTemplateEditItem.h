//
//  AUIVideoTemplateEditItem.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/22.
//

#import <UIKit/UIKit.h>
#import "AUIMusicPicker.h"
#import "AUIPhotoPicker.h"
#import "AlivcUgsvSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIVideoTemplateEditItemMedia;
@class AUIVideoTemplateEditItemText;
@class AUIVideoTemplateEditItemMusic;

@protocol AUIVideoTemplateEditItemProtocol <NSObject>

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy, readonly) UIImage *coverImage;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, readonly) NSTimeInterval duration;


@property (nonatomic, copy) void (^refreshCoverBlock)(id<AUIVideoTemplateEditItemProtocol> sender);
@property (nonatomic, copy) void (^refreshTextBlock)(id<AUIVideoTemplateEditItemProtocol> sender);
@property (nonatomic, copy) void (^refreshSelectedBlock)(id<AUIVideoTemplateEditItemProtocol> sender);

@property (nonatomic, strong, readonly) AUIVideoTemplateEditItemMedia *itemMedia;
@property (nonatomic, strong, readonly) AUIVideoTemplateEditItemText *itemText;
@property (nonatomic, strong, readonly) AUIVideoTemplateEditItemMusic *itemMusic;

@end





@interface AUIVideoTemplateEditItemMedia : NSObject<AUIVideoTemplateEditItemProtocol>

- (instancetype)initWithAsset:(AliyunAETemplateAssetMedia *)asset templatePath:(NSString *)templatePath;
- (void)updateClip:(nullable NSString *)clipPath cover:(nullable UIImage *)image;

@property (nonatomic, strong, readonly) AliyunAETemplateAssetMedia *asset;
@property (nonatomic, assign, readonly) BOOL isReplaced;
@property (nonatomic, strong) AUIPhotoPickerResult *pickerResult;

@end






@interface AUIVideoTemplateEditItemText : NSObject<AUIVideoTemplateEditItemProtocol>

- (instancetype)initWithAsset:(AliyunAETemplateAssetText *)asset;
- (void)updateText:(NSString *)text;

@property (nonatomic, strong, readonly) AliyunAETemplateAssetText *asset;

@end





typedef NS_ENUM(NSUInteger, AUIVideoTemplateEditMusicType) {
    AUIVideoTemplateEditMusicTypeNone = 0,
    AUIVideoTemplateEditMusicTypeTemplate,
    AUIVideoTemplateEditMusicTypeCustom,
};
@interface AUIVideoTemplateEditItemMusic : NSObject<AUIVideoTemplateEditItemProtocol>

- (instancetype)initWithMusicType:(AUIVideoTemplateEditMusicType)musicType;
- (void)updateMusicCustomSelectedModel:(AUIMusicSelectedModel *)selectedModel;

@property (nonatomic, assign, readonly) AUIVideoTemplateEditMusicType musicType;
@property (nonatomic, strong, readonly) AUIMusicSelectedModel *selectedModel;

@end

NS_ASSUME_NONNULL_END
