//
//  AUIEditorTrackerHeaderView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/24.
//

#import "AUIEditorTrackerHeaderView.h"

@implementation AUIEditorTrackerHeaderView

@synthesize volumeBtn = _volumeBtn;
@synthesize coverBtn = _coverBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (AVBaseButton *)volumeBtn {
    if (!_volumeBtn) {
        _volumeBtn = [AVBaseButton ImageTextWithTitlePos:AVBaseButtonTitlePosBottom];
        _volumeBtn.font = AVGetRegularFont(10.0);
        _volumeBtn.title = AUIUgsvGetString(@"原声");
        _volumeBtn.color = AUIFoundationColor(@"text_strong");
        _volumeBtn.image = AUIUgsvEditorImage(@"ic_menu_volume");
        _volumeBtn.selectedImage = AUIUgsvEditorImage(@"ic_tracker_volume");
        
        __weak typeof(self) weakSelf = self;
        _volumeBtn.action = ^(AVBaseButton * _Nonnull btn) {
            AUIEditorAudioUpdateVolumeActionItem *item = [AUIEditorAudioUpdateVolumeActionItem new];
            item.volume = btn.selected ? 1.0 : 0.0;
            item.forStreamIds = [weakSelf mainStreamIds];
            [weakSelf.actionManager doAction:item];
        };
        [self addSubview:_volumeBtn];
    }
    return _volumeBtn;
}

- (AVBaseButton *)coverBtn {
    if (!_coverBtn) {
        _coverBtn = [AVBaseButton ImageButton];
        _coverBtn.frame = CGRectMake(0, 0, 44, 44);
        _coverBtn.layer.cornerRadius = 4.0;
        _coverBtn.clipsToBounds = YES;
        _coverBtn.backgroundColor = AUIFoundationColor2(@"fill_infrared", 0.2);
        
        UILabel *label = [[UILabel alloc] initWithFrame:_coverBtn.bounds];
        label.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
        label.text = AUIUgsvGetString(@"设置封面");
        label.textColor = AUIFoundationColor(@"text_strong");
        label.font = AVGetMediumFont(8.0);
        label.textAlignment = NSTextAlignmentCenter;
        [_coverBtn addSubview:label];
        
        __weak typeof(self) weakSelf = self;
        _coverBtn.action = ^(AVBaseButton * _Nonnull btn) {
            [weakSelf startCapture];
        };
        [self addSubview:_coverBtn];
    }
    return _coverBtn;
}

- (void)setActionManager:(AUIEditorActionManager *)actionManager {
    _actionManager = actionManager;
    
    [self refreshVolumeState];
    [self refreshCover];
}

- (void)refreshVolumeState {
    __block BOOL isMute = YES;
    [[self.actionManager.currentOperator.currentEditor getEditorProject].timeline.mainVideoTrack.clipList enumerateObjectsUsingBlock:^(AEPVideoTrackClip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mixWeight > 0) {
            isMute = NO;
            *stop = YES;
        }
    }];
    self.volumeBtn.selected = isMute;
}

- (void)startCapture {
    UIImage *cover = [self.actionManager.currentOperator.currentPlayer screenCapture];
    if (cover) {
        [self.actionManager.currentOperator setAssociatedObject:cover forKey:@"cover"];
        _coverBtn.image = cover;
    }
}

-(void)refreshCover {
    UIImage *cover = [self.actionManager.currentOperator associatedObjectForKey:@"cover"];
    if (!cover) {
        [self startCapture];
    }
    else {
        _coverBtn.image = cover;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_coverBtn) {
        _coverBtn.frame = CGRectMake(self.av_width - 44 - 20, (self.av_height - 44) / 2.0, 44, 44);
    }
    
    if (_volumeBtn) {
        _volumeBtn.frame = CGRectMake((_coverBtn ? _coverBtn.av_left : self.av_width) - 44 - 20, (self.av_height - 44) / 2.0, 44, 44);
    }
}

- (NSArray<NSNumber *> *)mainStreamIds {
    NSMutableArray *arr = [NSMutableArray array];
    [[self.actionManager.currentOperator.currentEditor getEditorProject].timeline.mainVideoTrack.clipList enumerateObjectsUsingBlock:^(AEPVideoTrackClip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:@(obj.mediaId)];
    }];
    return arr;
}

+ (AUIEditorTrackerHeaderView *)main {
    AUIEditorTrackerHeaderView *view = [self new];
    view.volumeBtn.hidden = NO;
    view.coverBtn.hidden = NO;
    return view;
}

@end


@implementation AUIEditorTrackerHeaderViewLoader

- (instancetype)initWithHeaderView:(AUIEditorTrackerHeaderView *)headerView {
    self = [super init];
    if (self) {
        _headerView = headerView;
    }
    return self;
}

- (UIView *)loadHeaderView {
    return _headerView;
}

@end
