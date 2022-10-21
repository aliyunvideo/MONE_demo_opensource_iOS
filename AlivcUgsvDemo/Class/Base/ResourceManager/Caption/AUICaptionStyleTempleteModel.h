//
//  AUICaptionStyleTempleteModel.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import "AUIResourceModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUICaptionStyleTempleteModel : AUIResourceModel
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, strong) UIColor *outlineColor;
@property (nonatomic, assign) float outlineWidth;


@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) UIOffset shadowOffset;




@end

NS_ASSUME_NONNULL_END
