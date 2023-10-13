//
//  AUIVideoCrop.m
//  AlivcUGC_Demo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIVideoCrop.h"
#import "AUIAssetPlay.h"
#import "AUIVideoPreview.h"
#import "AUIVideoPlayTimeView.h"
#import "AUICropMainTimelineView.h"
#import "AUIUgsvMacro.h"
#import "AVAsset+UgsvHelper.h"

#import "AUIVideoCropExport.h"
#import "AUIMediaPublisher.h"


@interface AUIVideoCrop ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) AVAsset *cropAsset;
@property (nonatomic, strong) AUIVideoOutputParam *param;

@property (nonatomic, strong) AUIAssetPlay *player;

@property (nonatomic, strong) AUIVideoPreview *videoPreview;
@property (nonatomic, strong) AUIVideoPlayTimeView *playTimeView;
@property (nonatomic, strong) AUICropMainTimelineView *timelineView;

@end

@implementation AUIVideoCrop


- (instancetype)initWithFilePath:(NSString *)path withParam:(AUIVideoOutputParam *)param {
    self = [super init];
    if (self) {
        _filePath = path;
        NSURL *sourceURL = [NSURL fileURLWithPath:path];
        _cropAsset = [AVAsset assetWithURL:sourceURL];
        
        if (param && param.outputSizeType == AUIVideoOutputSizeTypeOriginal) {
            _param = [[AUIVideoOutputParam alloc] initWithOutputSize:[_cropAsset ugsv_getResolution] withAliyunVideoParam:param];
        }
        else {
            _param = param;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.headerLineView.hidden = NO;
    [self.menuButton setTitle:AUIUgsvGetString(@"下一步") forState:UIControlStateNormal];
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    self.menuButton.layer.cornerRadius = 12.0;
    self.menuButton.layer.masksToBounds = YES;
    [self.menuButton av_setLayerBorderColor:AUIFoundationColor(@"border_strong") borderWidth:1.0];
    self.menuButton.frame = CGRectMake(self.headerView.av_right - 20 - 60, (self.headerView.av_height - AVSafeTop - 24) / 2.0 + AVSafeTop, 60, 24);
    
    [self setupTimelineView:CGRectMake(0, self.contentView.av_height - 164 - AVSafeBottom, self.contentView.av_width, 164 + AVSafeBottom)];
    [self setupPlayTimeView:CGRectMake(0, self.timelineView.av_top - 42, self.contentView.av_width, 42)];
    [self setupPreviewView:CGRectMake(0, 0, self.contentView.av_width, self.playTimeView.av_top)];
    
    [self.player setDisplayViewScaleMode:self.param.scaleMode];
    [self.player play];
}

- (void)setupPreviewView:(CGRect)frame {
    CGSize outputSize = self.param ? self.param.outputSize : [_cropAsset ugsv_getResolution];
    self.videoPreview = [[AUIVideoPreview alloc] initWithFrame:frame withDisplayResolution:outputSize];
    [self.contentView addSubview:self.videoPreview];
    self.videoPreview.player = self.player;
}

- (void)setupPlayTimeView:(CGRect)frame {
    self.playTimeView = [[AUIVideoPlayTimeView alloc] initWithFrame:frame];
    [self.contentView addSubview:self.playTimeView];
    __weak typeof(self) weakSelf = self;
    self.playTimeView.onFullScreenBtnClicked = ^(BOOL fullScreen){
        [weakSelf.videoPreview enterFullScreen:weakSelf.view];
    };
    self.playTimeView.player = self.player;
}

- (void)setupTimelineView:(CGRect)frame {
    self.timelineView = [[AUICropMainTimelineView alloc] initWithFrame:frame withAssetPlayer:self.player];
    [self.contentView addSubview:self.timelineView];
}

- (AUIAssetPlay *)player {
    if (!_player) {
        if (!self.cropAsset) {
            return nil;
        }
        _player = [[AUIAssetPlay alloc] initWithAsset:self.cropAsset];
        _player.isLoopPlay = YES;
    }
    return _player;
}

- (void)onMenuClicked:(UIButton *)sender {
    [self.player pause];
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        CGRect cropRect;
        cropRect.size = [self.cropAsset ugsv_getResolution];
        if (self.param) {
            CGSize aspectSize = [UIView av_aspectSizeWithOriginalSize:cropRect.size withResolution:self.param.outputSize];
            cropRect = CGRectMake(CGRectGetMidX(cropRect) - aspectSize.width / 2.0, CGRectGetMidY(cropRect) - aspectSize.height / 2.0, aspectSize.width, aspectSize.height);
        }
        
        AUIVideoCropExport *export = [[AUIVideoCropExport alloc] initWithVideoFilePath:self.filePath startTime:self.timelineView.clipStart endTime:self.timelineView.clipEnd cropRect:cropRect param:self.param];
        export.saveToAlbumExportCompleted = self.saveToAlbumExportCompleted;
        export.requestCoverImageBlock = ^(void (^ _Nonnull completedBlock)(UIImage * _Nonnull)) {
            UIImage *cover = [weakSelf.player screenCapture];
            if (completedBlock) {
                completedBlock(cover);
            }
        };
        
        void (^onFinish)(UIViewController *, NSError *, id) = ^(UIViewController *current, NSError * _Nullable error, id  _Nullable product) {
            if (error) {
                [AVAlertController showWithTitle:AUIUgsvGetString(@"出错了") message:error.description needCancel:NO onCompleted:^(BOOL isCanced) {
                    [current.navigationController popToViewController:weakSelf animated:YES];
                }];
            }
            else {
                BOOL isPublish = [current isKindOfClass:AUIMediaPublisher.class];
                [AVAlertController showWithTitle:nil message:isPublish ? AUIUgsvGetString(@"发布成功") : AUIUgsvGetString(@"导出成功") needCancel:NO onCompleted:^(BOOL isCanced) {
                    [current.navigationController popToViewController:weakSelf animated:YES];
                }];
            }
        };
        
        UIViewController *pvc = nil;
        if (self.needToPublish) {
            AUIMediaPublisher *publisher = [[AUIMediaPublisher alloc] initWithExportProgress:export];
            publisher.onFinish = onFinish;
            pvc = publisher;
        }
        else {
            AUIMediaProgressViewController *progressVC = [[AUIMediaProgressViewController alloc] initWithHandle:export];
            progressVC.onFinish = onFinish;
            pvc = progressVC;
        }
        [self.navigationController pushViewController:pvc animated:YES];
    });
}

@end
