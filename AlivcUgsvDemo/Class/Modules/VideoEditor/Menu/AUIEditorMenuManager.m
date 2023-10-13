//
//  AUIEditorMenuManager.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUIEditorMenuManager.h"
#import "AUIUgsvMacro.h"

@interface AUIEditorMenuManager ()

@property (nonatomic, strong) AUIEditorMenuGroup *group;

@end

@implementation AUIEditorMenuManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.group = [self.class mainGroup];
    }
    return self;
}

- (AUIEditorMenuGroup *)currentGroup {
    return self.group;
}

+ (AUIEditorMenuGroup *)creatGroup:(AUIEditorMenuGroupType)type items:(NSArray *)items {
    AUIEditorMenuGroup *group = [AUIEditorMenuGroup new];
    group.type = type;
    group.items = items;
    return group;
}

+ (AUIEditorMenuItem *)creatItem:(NSString *)text icon:(NSString *)icon type:(AUIEditorMenuItemType)type {
    AUIEditorMenuItem *item = [AUIEditorMenuItem new];
    item.text = text;
    item.icon = icon;
    item.type = type;
    item.enable = YES;
    return item;
}

+ (AUIEditorMenuGroup *)mainGroup {
    return [self creatGroup:AUIEditorMenuGroupTypeMain items:@[
        [self audioItem],
        [self videoItem],
        [self captionItem],
        [self stickerItem],
        [self filterItem],
        [self effectItem],]];
}

+ (AUIEditorMenuItem *)videoItem {
    return [self creatItem:AUIUgsvGetString(@"剪辑") icon:@"ic_menu_video" type:AUIEditorMenuItemTypeVideo];
}

+ (AUIEditorMenuItem *)audioItem {
    return [self creatItem:AUIUgsvGetString(@"音乐") icon:@"ic_menu_audio" type:AUIEditorMenuItemTypeAudio];
}

+ (AUIEditorMenuItem *)captionItem {
    return [self creatItem:AUIUgsvGetString(@"文字") icon:@"ic_menu_caption" type:AUIEditorMenuItemTypeCaption];
}

+ (AUIEditorMenuItem *)stickerItem {
    return [self creatItem:AUIUgsvGetString(@"贴纸") icon:@"ic_menu_sticker" type:AUIEditorMenuItemTypeSticker];
}

+ (AUIEditorMenuItem *)filterItem {
    return [self creatItem:AUIUgsvGetString(@"滤镜") icon:@"ic_menu_filter" type:AUIEditorMenuItemTypeFilter];
}

+ (AUIEditorMenuItem *)effectItem {
    return [self creatItem:AUIUgsvGetString(@"特效") icon:@"ic_menu_effect" type:AUIEditorMenuItemTypeEffect];
}

@end
