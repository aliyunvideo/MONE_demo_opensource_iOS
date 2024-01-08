//
//  AUIVideoCutter.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/12/9.
//

#import "AUIVideoCutter.h"
#import "AUIUgsvMacro.h"
#import "AVAsset+UgsvHelper.h"
#import "AUIAssetPlay.h"
#import "AUIVideoCutterBottomPanel.h"
#import "AUICropPreview.h"
#import "Masonry.h"

@implementation AUIVideoCutterParam

@end

@implementation AUIVideoCutterResult

@end

@interface AUIVideoCutter ()<AUICropBottomPanelDelegate>
@property (nonatomic, readonly) BOOL isImage;
@property (nonatomic, strong) AUIVideoCutterParam *param;
@property (nonatomic, copy) OnCutCompleted completed;

@property (nonatomic, strong) AVAsset *cropAsset;
@property (nonatomic, strong) AUIAssetPlay *player;

@property (nonatomic, strong) AUICropPreview *preview;
@property (nonatomic, strong) AUIVideoCutterBottomPanel *bottomPanel;
@end

@implementation AUIVideoCutter

- (instancetype)initWithParam:(AUIVideoCutterParam *)param completed:(OnCutCompleted)completed {
    self = [super init];
    if (self) {
        self.param = param;
        self.completed = completed;
        
        self.cropAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:param.inputPath]];
        self.player = [[AUIAssetPlay alloc] initWithAsset:self.cropAsset];
        
        [self setupBottomPanel];
        [self setupPreview];
        [self setupTips];
        
        [self.player play];
        [self.player pause];
    }
    return self;
}

- (BOOL) isImage {
    return self.param.isImage;
}

- (void)setupTips {
    UILabel *label = [UILabel new];
    label.backgroundColor = UIColor.clearColor;
    label.textColor = AUIFoundationColor(@"text_strong");
    label.font = AVGetRegularFont(10.0);
    label.text = AUIUgsvGetString(@"拖动调整内容显示区域");
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.preview.mas_top).inset(15.0);
    }];
}

- (void)setupPreview {
    AUICropPreviewContent *content = nil;
    if (self.isImage) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.param.inputPath];
        content = [[AUICropPreviewContent alloc] initWithImage:image];
    } else {
        CGSize resolution = [self.cropAsset ugsv_getResolution];
        content = [[AUICropPreviewContent alloc] initWithVideo:self.player resolution:resolution];
    }
    
    _preview = [[AUICropPreview alloc] initWithContent:content outputResolution:self.param.outputAspectRatio];
    [self.view addSubview:_preview];
    [_preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).inset(112.0);
        make.bottom.equalTo(self.bottomPanel.mas_top).inset(15.0);
    }];
}

- (void)setupBottomPanel {
    if (self.isImage) {
        _bottomPanel = [[AUIVideoCutterBottomPanel alloc] initForImage];
    } else {
        _bottomPanel = [[AUIVideoCutterBottomPanel alloc] initWithPlayer:self.player
                                                         filePath:self.param.inputPath
                                                     cropDuration:self.param.outputDuration];
    }
    _bottomPanel.delegate = self;
    [self.view addSubview:_bottomPanel];
    [_bottomPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.headerLineView.hidden = YES;
    self.headerView.hidden = YES;
}

// MARK: - AUICropBottomPanelDelegate
- (void) onAUICropBottomPanel:(AUIVideoCutterBottomPanel *)panel didConfirm:(BOOL)confirm {
    AUIVideoCutterResult *result = nil;
    if (confirm) {
        result = [AUIVideoCutterResult new];
        result.startTime = self.bottomPanel.startTime;
        result.frame = self.preview.cropRect;
    }
    BOOL dismiss = YES;
    if (self.completed) {
        dismiss = self.completed(!confirm, self.param, result, self);
    }
    
    if (dismiss) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
