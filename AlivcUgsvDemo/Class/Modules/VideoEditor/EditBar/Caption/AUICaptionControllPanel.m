//
//  AUICaptionControllPanel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//

#import "AUICaptionControllPanel.h"
#import "AUICaptionFlowerView.h"
#import "AUISegementView.h"
#import "AUICaptionInputView.h"
#import "UIView+AVHelper.h"
#import "AUICaptionAnimationView.h"
#import "AUICaptionBubbleView.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import "AUICaptionStyleView.h"
#import "AUIPanelStatusButtonView.h"
#import "AUIStickerModel.h"
#import "AUICaptionAnimationModel.h"



@interface AUICaptionControllPanel ()
@property (nonatomic, strong) AUICaptionInputView *textInputView;
@property (nonatomic, strong) AUISegementView *segment;
@property (nonatomic, strong) NSArray *segmenTitles;
@property (nonatomic, strong) AUICaptionFlowerView *flowerView;
@property (nonatomic, strong) AUICaptionAnimationView *animationView;
@property (nonatomic, strong) AUICaptionBubbleView *bubbleView;
@property (nonatomic, strong) AUICaptionStyleView *styleView;

@property (nonatomic, weak) AliyunCaptionStickerController *stickerController;


@end

@implementation AUICaptionControllPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.showBackButton = YES;
        
        self.segmenTitles = @[AUIUgsvGetString(@"花字"),AUIUgsvGetString(@"气泡"),AUIUgsvGetString(@"样式"),AUIUgsvGetString(@"动画")];
        [self.headerView addSubview:self.textInputView];
        [self.contentView addSubview:self.segment];
        [self.contentView addSubview:self.flowerView];
        [self.contentView addSubview:self.animationView];
        [self.contentView addSubview:self.bubbleView];
        [self.contentView addSubview:self.styleView];


        [self addNotifications];
    }
    return self;
}

+ (CGFloat)panelHeight
{
    return 240 + AVSafeBottom;
}

- (AUICaptionInputView *)textInputView
{
    if (!_textInputView) {
        _textInputView = [[AUICaptionInputView alloc] initWithFrame:CGRectMake(58, 0, self.av_width - 58 *2, self.headerView.av_height)];
        
        __weak typeof(self) weakSelf = self;

        _textInputView.onTextChanged = ^(NSString * _Nonnull text) {
            if (text.length == 0) {
                weakSelf.stickerController.model.text = AUIUgsvGetString(@"点击输入文字");
            } else {
                weakSelf.stickerController.model.text = text;
            }
        };
    }
    return _textInputView;
}

- (AUISegementView *)segment
{
    if (!_segment) {
        _segment = [[AUISegementView alloc] initWithTitles:self.segmenTitles];
        _segment.frame = CGRectMake(0, 0, self.bounds.size.width, 30);
        
        __weak typeof(self) weakSelf = self;

        _segment.onSelectedChanged = ^(NSUInteger selectedType) {
            weakSelf.flowerView.hidden = selectedType != 0;
            weakSelf.bubbleView.hidden = selectedType != 1;
            weakSelf.styleView.hidden = selectedType != 2;
            weakSelf.animationView.hidden = selectedType != 3;
            
            [weakSelf.textInputView textViewResignFirstResponder];

        };
    }
    return _segment;
}

- (AliyunCaptionStickerController *)stickerController {
    return self.aep.captionStickerController;
}

- (void)setAep:(AEPCaptionTrack *)aep {
    _aep = aep;
    self.styleView.stickerController = self.stickerController;
    self.flowerView.stickerController = self.stickerController;
    self.bubbleView.stickerController = self.stickerController;
    self.animationView.stickerController = self.stickerController;
    __weak typeof(_animationView) weakView = _animationView;
    __weak typeof(self) weakSelf = self;
    _animationView.onSelectedChanged = ^(AUIFilterModel * _Nonnull model) {
        [weakSelf.actionManger.currentOperator.currentPlayer pause];
        
        AUICaptionAnimationModel *ani = model;
        [weakView didSeletedAnimateWithType:ani.actionType];
    };
    [self.textInputView setTextViewText:self.stickerController.model.text];
}

- (AUICaptionFlowerView *)flowerView
{
    if (!_flowerView) {
        _flowerView = [[AUICaptionFlowerView alloc] initWithFrame:CGRectMake(0, self.segment.av_height, self.segment.av_width, self.contentView.av_height - self.segment.av_height)];
        [_flowerView selectWithIndex:0];
        __weak typeof(self) weakSelf = self;
        _flowerView.onSelectedChanged = ^(AUIStickerModel * _Nonnull model) {
            AliyunCaptionSticker *caption = weakSelf.stickerController.model;
            caption.fontEffectTemplatePath = model.resourcePath;
        };
    }
    return _flowerView;
}

- (AUICaptionBubbleView *)bubbleView
{
    if (!_bubbleView) {
        
        _bubbleView = [[AUICaptionBubbleView alloc] initWithFrame:self.flowerView.frame];
        _bubbleView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        [_bubbleView selectWithIndex:0];
        _bubbleView.onSelectedChanged = ^(AUIStickerModel * _Nonnull model) {
            AliyunCaptionSticker *caption = weakSelf.stickerController.model;
            caption.resourePath = model.resourcePath;
        };
    }
    return _bubbleView;
}

- (AUICaptionStyleView *)styleView
{
    if (!_styleView) {
        _styleView = [[AUICaptionStyleView alloc] initWithFrame:self.flowerView.frame];
        _styleView.hidden = YES;
    }

    return _styleView;
}


- (AUICaptionAnimationView *)animationView
{
    if (!_animationView) {
        
        _animationView = [[AUICaptionAnimationView alloc] initWithFrame:CGRectMake(0, self.segment.av_height + 20, self.segment.av_width, 70)];
        _animationView.hidden = YES;
    }
    return _animationView;
}


#pragma mark - intputNotifications

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShowAction:(NSNotification *)noti
{
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat top =  [UIScreen mainScreen].bounds.size.height - keyboardFrame.size.height - self.headerView.av_height - self.segment.av_height;
    [UIView animateWithDuration:animationDuration animations:^{
        self.av_top = top;
    }];
    if (self.onKeyboardShowChanged) {
        self.onKeyboardShowChanged(YES, top);
    }
}

- (void)keyboardWillHideAction:(NSNotification *)noti
{
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat top = [UIScreen mainScreen].bounds.size.height - self.av_height;
    [UIView animateWithDuration:animationDuration animations:^{
        self.av_top = top;
    }];
    if (self.onKeyboardShowChanged) {
        self.onKeyboardShowChanged(YES, top);
    }
}
- (void)textViewResignFirstResponder
{
    [self.textInputView textViewResignFirstResponder];
}
@end
