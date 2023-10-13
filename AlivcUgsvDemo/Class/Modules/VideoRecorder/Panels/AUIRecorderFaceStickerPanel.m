//
//  AUIRecorderFaceStickerPanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/6.
//

#import "AUIRecorderFaceStickerPanel.h"
#import "AUIStickerView.h"
#import "AUIStickerModel.h"
#import "AUIResourceManager.h"
#import "AUIUgsvMacro.h"
#import "Masonry.h"

@interface AUIRecorderFaceStickerView : AUIStickerView
@end

@implementation AUIRecorderFaceStickerView

- (void) fetchData {
    __weak typeof(self) weakSelf = self;
    [AUIResourceManager.manager fetchFaceStickerDataWithCallback:^(NSError *error, NSArray *data) {
        NSMutableArray *result = data.mutableCopy;
        [result insertObject:[AUIStickerModel EmptyModel] atIndex:0];
        [weakSelf updateDataSource:result];
        [weakSelf selectWithIndex:0];
    }];
}

@end

@interface AUIRecorderFaceStickerPanel ()
@property (nonatomic, strong) AUIRecorderFaceStickerView *stickerView;
@end

@implementation AUIRecorderFaceStickerPanel

+ (AUIRecorderFaceStickerPanel *) present:(UIView *)superView onSelectedChange:(OnFaceStickerSelectedChanged)selectedChanged {
    
    AUIRecorderFaceStickerPanel *panel = [[AUIRecorderFaceStickerPanel alloc] initWithFrame:superView.bounds];
    panel.onSelectedChanged = selectedChanged;
    [panel showOnView:superView];

    return panel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleView.text = AUIUgsvGetString(@"道具");
        _stickerView = [[AUIRecorderFaceStickerView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_stickerView];
        [_stickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).inset(AVSafeBottom);
        }];
    }
    return self;
}

- (void) setOnSelectedChanged:(OnFaceStickerSelectedChanged)onSelectedChanged {
    self.stickerView.onSelectedChanged = onSelectedChanged;
}
- (OnFaceStickerSelectedChanged) onSelectedChanged {
    return self.stickerView.onSelectedChanged;
}

@end
