//
//  AUIVideoTemplateOutputParam.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIVideoTemplateOutputParam : NSObject

@property (nonatomic, copy, nullable) NSString *outputPath;
@property (nonatomic, assign) float bpp;  // 码率系数为0 则使用默认值
@property (nonatomic, assign) BOOL saveToAlbumExportCompleted;
@property (nonatomic, assign) BOOL needToPublish;

@end

NS_ASSUME_NONNULL_END
