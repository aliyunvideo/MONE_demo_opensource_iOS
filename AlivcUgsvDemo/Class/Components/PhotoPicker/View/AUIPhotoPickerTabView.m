//
//  AUIPhotoPickerTabView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/27.
//

#import "AUIPhotoPickerTabView.h"
#import "AUIUgsvMacro.h"

@interface AUIPhotoPickerTabView ()

@property (nonatomic, strong) UIButton *allButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIView *selectedLineView;

@property (nonatomic, assign) AUIPhotoPickerTabType tabType;
@property (nonatomic, copy) void (^tabChangedBlock)(AUIPhotoPickerTabType type);

@end

@implementation AUIPhotoPickerTabView

- (instancetype)initWithFrame:(CGRect)frame withTabChangedBlock:(void (^)(AUIPhotoPickerTabType type))tabChangedBlock {
    self = [super initWithFrame:frame];
    if (self) {
        _tabChangedBlock = tabChangedBlock;
        
        _allButton = [UIButton new];
        [_allButton setTitle:AUIUgsvGetString(@"全部") forState:UIControlStateNormal];
        [_allButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
        [_allButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _allButton.titleLabel.font = AVGetMediumFont(14);
        [_allButton addTarget:self action:@selector(onTabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_allButton];
        
        _videoButton = [UIButton new];
        [_videoButton setTitle:AUIUgsvGetString(@"视频") forState:UIControlStateNormal];
        [_videoButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
        [_videoButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _videoButton.titleLabel.font = AVGetRegularFont(14);
        [_videoButton addTarget:self action:@selector(onTabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_videoButton];
        
        _imageButton = [UIButton new];
        [_imageButton setTitle:AUIUgsvGetString(@"图片") forState:UIControlStateNormal];
        [_imageButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
        [_imageButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        _imageButton.titleLabel.font = AVGetRegularFont(14);
        [_imageButton addTarget:self action:@selector(onTabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_imageButton];
        
        [_allButton sizeToFit];
        [_imageButton sizeToFit];
        [_videoButton sizeToFit];
        
        CGFloat height = 22;
        CGFloat y = (self.av_height - height) / 2.0;
        CGFloat width = MAX(_videoButton.av_width, _imageButton.av_width);
        width = MAX(_allButton.av_width, width);
        width = MAX(56, width);
        CGFloat margin = (self.av_width - 20 * 2 - width * 3) / 4.0;
        _allButton.frame = CGRectMake(20 + margin, y, width, height);
        _videoButton.frame = CGRectMake(_allButton.av_right + margin, y, width, height);
        _imageButton.frame = CGRectMake(_videoButton.av_right + margin, y, width, height);
        
        _selectedLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 2)];
        _selectedLineView.backgroundColor = AUIFoundationColor(@"fill_infrared");
        [self addSubview:_selectedLineView];

        _tabType = AUIPhotoPickerTabTypeAll;
        [self onTabTypeChanged:NO];
    }
    return self;
}

- (void)setTabType:(AUIPhotoPickerTabType)tabType {
    if (_tabType == tabType) {
        return;
    }
    
    _tabType = tabType;
    [self onTabTypeChanged:YES];
}

- (void)onTabButtonClicked:(UIButton *)sender {
    if (sender == self.imageButton) {
        [self setTabType:AUIPhotoPickerTabTypeImage];
    }
    else if (sender == self.videoButton) {
        [self setTabType:AUIPhotoPickerTabTypeVideo];
    }
    else {
        [self setTabType:AUIPhotoPickerTabTypeAll];
    }
}

- (void)onTabTypeChanged:(BOOL)notify {
    CGPoint center = CGPointMake(self.allButton.center.x, self.allButton.av_bottom + 4);
    if (self.tabType == AUIPhotoPickerTabTypeImage) {
        self.allButton.selected = NO;
        self.videoButton.selected = NO;
        self.imageButton.selected = YES;
        self.allButton.titleLabel.font = AVGetRegularFont(14);
        self.videoButton.titleLabel.font = AVGetRegularFont(14);
        self.imageButton.titleLabel.font = AVGetMediumFont(14);
        center.x = self.imageButton.center.x;
    }
    else if (self.tabType == AUIPhotoPickerTabTypeVideo) {
        self.allButton.selected = NO;
        self.videoButton.selected = YES;
        self.imageButton.selected = NO;
        self.allButton.titleLabel.font = AVGetRegularFont(14);
        self.videoButton.titleLabel.font = AVGetMediumFont(14);
        self.imageButton.titleLabel.font = AVGetRegularFont(14);
        center.x = self.videoButton.center.x;
    }
    else {
        self.allButton.selected = YES;
        self.videoButton.selected = NO;
        self.imageButton.selected = NO;
        self.allButton.titleLabel.font = AVGetMediumFont(14);
        self.videoButton.titleLabel.font = AVGetRegularFont(14);
        self.imageButton.titleLabel.font = AVGetRegularFont(14);
        center.x = self.allButton.center.x;
    }
    if (notify) {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectedLineView.center = center;
        } completion:^(BOOL finished) {
            self.selectedLineView.center = center;
        }];
        if (self.tabChangedBlock) {
            self.tabChangedBlock(self.tabType);
        }
    }
    else {
        self.selectedLineView.center = center;
    }
}

@end
