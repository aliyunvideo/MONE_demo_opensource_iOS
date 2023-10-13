//
//  AUIVideoTemplateEditMenuData.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIVideoTemplateEditMenuType) {
    AUIVideoTemplateEditMenuTypeMedia,
    AUIVideoTemplateEditMenuTypeText,
    AUIVideoTemplateEditMenuTypeMusic,
    
    AUIVideoTemplateEditMenuTypePopReplace,
    AUIVideoTemplateEditMenuTypePopCrop,
    AUIVideoTemplateEditMenuTypePopDelete,
};


@interface AUIVideoTemplateEditMenuData : NSObject

@property (nonatomic, assign) AUIVideoTemplateEditMenuType type;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *normalIcon;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy) void (^onClickBlock)(AUIVideoTemplateEditMenuData *sender);

@end

NS_ASSUME_NONNULL_END
