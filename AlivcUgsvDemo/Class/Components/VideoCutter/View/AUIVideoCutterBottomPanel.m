//
//  AUIVideoCutterBottomPanel.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/9.
//

#import "AUIVideoCutterBottomPanel.h"
#import "AUIUgsvMacro.h"
#import "AUICropTimelineView.h"
#import "Masonry.h"
#import "AUIFoundation.h"

@interface AUIVideoCutterBottomPanel()
@property (nonatomic, strong) AUICropTimelineView *timelineView;
@property (nonatomic, strong) UIView *contentContainer;
@end

@implementation AUIVideoCutterBottomPanel

- (instancetype)initForImage {
    return [self initWithPlayer:NULL filePath:NULL cropDuration:0];
}

- (instancetype)initWithPlayer:(nullable id<AUIVideoPlayProtocol>)player
                      filePath:(nullable NSString *)filePath
                  cropDuration:(NSTimeInterval)cropDuration {
    self = [super init];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        [self setupContent:player cropDuration:cropDuration filePath:filePath];
        [self setupHeader];
    }
    return self;
}

- (void)onFinish:(BOOL)isConfirm {
    if ([_delegate respondsToSelector:@selector(onAUICropBottomPanel:didConfirm:)]) {
        [_delegate onAUICropBottomPanel:self didConfirm:isConfirm];
    }
}

- (NSTimeInterval) startTime {
    return self.timelineView.startTime;
}

- (void)setupHeader {
    UIView *header = [UIView new];
    [self addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(46);
        make.left.right.top.equalTo(self);
        make.bottom.equalTo(_contentContainer.mas_top);
    }];
    
    UIView *headerLine = [UIView new];
    headerLine.backgroundColor = AUIFoundationColor(@"fg_strong");
    [header addSubview:headerLine];
    [headerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1.0);
        make.left.right.bottom.equalTo(header);
    }];
    
    UILabel *title = [UILabel new];
    title.font = AVGetRegularFont(14);
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = AUIFoundationColor(@"text_strong");
    title.text = AUIUgsvGetString(@"裁剪");
    [header addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(header);
    }];
    
    __weak typeof(self) weakSelf = self;
    AVBaseButton *closeBtn = [AVBaseButton ImageButton];
    closeBtn.image = AUIUgsvEditorImage(@"ic_status_closemark");
    [closeBtn setAction:^(AVBaseButton *btn) {
        [weakSelf onFinish:NO];
    }];
    [header addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22.0);
        make.centerY.equalTo(header);
        make.left.equalTo(header).inset(20.0);
    }];
    
    AVBaseButton *confirmBtn = [AVBaseButton ImageButton];
    confirmBtn.image = AUIUgsvEditorImage(@"ic_status_checkmark");
    [confirmBtn setAction:^(AVBaseButton * _Nonnull btn) {
        [weakSelf onFinish:YES];
    }];
    [header addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22.0);
        make.centerY.equalTo(header);
        make.right.equalTo(header).inset(20.0);
    }];
}

- (void)setupContent:(id<AUIVideoPlayProtocol>)player cropDuration:(NSTimeInterval)cropDuration filePath:(NSString *)filePath {
    _contentContainer = [UIView new];
    [self addSubview:_contentContainer];
    if (player) {
        _timelineView = [[AUICropTimelineView alloc] initWithPlayer:player cropDuration:cropDuration filePath:filePath];
        [_contentContainer addSubview:_timelineView];
        [_timelineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_contentContainer);
        }];
    }

    [_contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(player ? 140.0 : 1.0);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).inset(AVSafeBottom);
    }];
}

@end
