//
//  AUIVideoOutputParam.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/8.
//

#import <Foundation/Foundation.h>
#import "AlivcUgsvSDKHeader.h"
#import "AUIUgsvParamBuilder.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIVideoOutputSizeRatio) {
    AUIVideoOutputSizeRatio_original = 0, // AliyunVideoParam.outputSize.width :  AliyunVideoParam.outputSize.height
    AUIVideoOutputSizeRatio_9_16,
    AUIVideoOutputSizeRatio_3_4,
    AUIVideoOutputSizeRatio_1_1,
    AUIVideoOutputSizeRatio_16_9,
    AUIVideoOutputSizeRatio_4_3,
};

typedef NS_ENUM(NSUInteger, AUIVideoOutputSizeType) {
    AUIVideoOutputSizeTypeCustom = 0,
    AUIVideoOutputSizeType480P,
    AUIVideoOutputSizeType540P,
    AUIVideoOutputSizeType720P,
    AUIVideoOutputSizeType1080P,
    AUIVideoOutputSizeTypeOriginal
};

@interface AUIVideoOutputParam : AliyunVideoParam

@property(nonatomic, assign, readonly) CGSize outputSize;
@property(nonatomic, assign, readonly) AUIVideoOutputSizeRatio outputSizeRatio;
@property(nonatomic, assign, readonly) AUIVideoOutputSizeType outputSizeType;

- (instancetype)initWithOutputSize:(CGSize)outputSize;
- (instancetype)initWithOutputSizeType:(AUIVideoOutputSizeType)type ratio:(AUIVideoOutputSizeRatio)ratio;
- (instancetype)initWithOutputSize:(CGSize)outputSize withAliyunVideoParam:(AliyunVideoParam *)videoParam;


+ (AUIVideoOutputParam *)original;

+ (AUIVideoOutputParam *)Portrait480P;
+ (AUIVideoOutputParam *)Portrait540P;
+ (AUIVideoOutputParam *)Portrait720P;
+ (AUIVideoOutputParam *)Portrait1080P;

+ (AUIVideoOutputParam *)Landscape480P;
+ (AUIVideoOutputParam *)Landscape540P;
+ (AUIVideoOutputParam *)Landscape720P;
+ (AUIVideoOutputParam *)Landscape1080P;

@end

@interface AUIVideoOutputParam (ParamBuilder)

- (AUIUgsvParamBuilder *)paramBuilder;

- (AUIUgsvParamBuilder *)paramBuilderWithoutAudioParam;

@end

NS_ASSUME_NONNULL_END
