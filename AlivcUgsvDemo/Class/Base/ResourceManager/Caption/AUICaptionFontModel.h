//
//  AUICaptionFontModel.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import "AUIResourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUICaptionFontModel : AUIResourceModel

@property (nonatomic, strong) NSString *showName;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) float pority;//排序0-1000
@end

NS_ASSUME_NONNULL_END
