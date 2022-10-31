//
//  AUIEditorMenuItem.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AUIEditorMenuGroupType) {
    AUIEditorMenuGroupTypeMain,
};

@class AUIEditorMenuItem;
@interface AUIEditorMenuGroup : NSObject

@property (nonatomic, copy) NSArray<AUIEditorMenuItem *> *items;
@property (nonatomic, assign) AUIEditorMenuGroupType type;

@end

typedef NS_ENUM(NSUInteger, AUIEditorMenuItemType) {
    AUIEditorMenuItemTypeVideo,
    AUIEditorMenuItemTypeAudio,
    AUIEditorMenuItemTypeCaption,
    AUIEditorMenuItemTypeSticker,
    AUIEditorMenuItemTypeFilter,
    AUIEditorMenuItemTypeEffect,
};

@interface AUIEditorMenuItem : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, assign) AUIEditorMenuItemType type;
@property (nonatomic, assign) BOOL enable;

@end

