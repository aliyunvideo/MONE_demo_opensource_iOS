//
//  AUIEditorSelectStickerPanel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import "AUIEditorSelectStickerPanel.h"
#import "AUIStickerView.h"
#import "AUIStickerModel.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import "AUIResourceManager.h"



@interface AUIEditorStickerView : AUIStickerView

@end


@implementation AUIEditorStickerView

- (void)fetchData
{
    [[AUIResourceManager manager] fetchStickerDataWithCallBack:^(NSError *error, NSArray *data) {
        [self updateDataSource:data];
    }];
}

@end

@interface AUIEditorSelectStickerPanel()

@property (nonatomic, strong) AUIEditorStickerView *stickerView;

@end

@implementation AUIEditorSelectStickerPanel

+ (CGFloat)panelHeight {
    return 240 + AVSafeBottom;
}

- (AUIEditorStickerView *)stickerView
{
    if (!_stickerView) {
        _stickerView = [[AUIEditorStickerView alloc] initWithFrame:self.contentView.bounds];
        __weak typeof(self) weakSelf = self;
        _stickerView.onSelectedChanged = ^(AUIStickerModel * _Nonnull model) {
            AUIEditorStickerAddActionItem *item = [AUIEditorStickerAddActionItem new];
            item.input = model;
            [weakSelf.actionManager doAction:item];
            [weakSelf hide];
        };
    }
    return _stickerView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleView.text = nil;
        [self.contentView addSubview:self.stickerView];
        self.showBackButton = YES;
    }
    
    return self;
}

@end
