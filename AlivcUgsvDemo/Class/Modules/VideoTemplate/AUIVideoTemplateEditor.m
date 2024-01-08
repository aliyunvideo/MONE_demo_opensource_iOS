//
//  AUIVideoTemplateEditor.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/9/22.
//

#import "AUIVideoTemplateEditor.h"
#import "AUITemplatePlay.h"
#import "AUIVideoPreview.h"
#import "AUIVideoPlayProgressView.h"
#import "AUIUgsvMacro.h"
#import "AUIVideoTemplateEditBar.h"

#import "AUIVideoTemplateExport.h"
#import "AUIMediaPublisher.h"
#import "AUIPhotoPicker.h"
#import "AUIUgsvPath.h"
#import "AUIVideoTemplateResouce.h"

#import "AlivcUgsvSDKHeader.h"
#import <SDWebImage/SDWebImage.h>

@interface AUIVideoTemplateEditor () <AUIVideoPlayObserver>

@property (nonatomic, copy) NSString *templatePath;

@property (nonatomic, strong) AUITemplatePlay *player;
@property (nonatomic, strong) AliyunAETemplateEditor *editor;

@property (nonatomic, copy) NSArray<NSArray<AUIVideoTemplateEditItemProtocol> *> *editItems;

@property (nonatomic, strong) AUIVideoPreview *videoPreview;
@property (nonatomic, strong) AUIVideoPlayProgressView *playProgressView;
@property (nonatomic, strong) UIView *selectedNodeView;
@property (nonatomic, strong) AUIVideoTemplateEditBar *editBar;

@end

@implementation AUIVideoTemplateEditor

- (void)dealloc {
    [self.player stop];
    self.editor = nil;
}

- (instancetype)initWithTemplatePath:(NSString *)templatePath {
    self = [super init];
    if (self) {
        _templatePath = templatePath;
        _editor = [[AliyunAETemplateEditor alloc] initWithTemplatePath:_templatePath];
        [self loadEditItems];
    }
    return self;
}

- (void)loadEditItems {
    NSMutableArray<AUIVideoTemplateEditItemMedia *> *clipItems = [NSMutableArray array];
    NSMutableArray<AUIVideoTemplateEditItemText *> *textItems = [NSMutableArray array];
    [self.editor.currentTemplate.replaceableAssets enumerateObjectsUsingBlock:^(AliyunAETemplateAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:AliyunAETemplateAssetMedia.class]) {
            AUIVideoTemplateEditItemMedia *item = [[AUIVideoTemplateEditItemMedia alloc] initWithAsset:(AliyunAETemplateAssetMedia *)obj templatePath:self.editor.currentTemplate.path];
            [clipItems addObject:item];
        }
        else if ([obj isKindOfClass:AliyunAETemplateAssetText.class]) {
            AUIVideoTemplateEditItemText *item = [[AUIVideoTemplateEditItemText alloc] initWithAsset:(AliyunAETemplateAssetText *)obj];
            [textItems addObject:item];
        }
    }];
    
    NSMutableArray *musicItems = [NSMutableArray array];
    AUIVideoTemplateEditItemMusic *item1 = [[AUIVideoTemplateEditItemMusic alloc] initWithMusicType:AUIVideoTemplateEditMusicTypeNone];
    [musicItems addObject:item1];
    AUIVideoTemplateEditItemMusic *item2 = [[AUIVideoTemplateEditItemMusic alloc] initWithMusicType:AUIVideoTemplateEditMusicTypeTemplate];
    item2.selected = YES;
    [musicItems addObject:item2];
    AUIVideoTemplateEditItemMusic *item3 = [[AUIVideoTemplateEditItemMusic alloc] initWithMusicType:AUIVideoTemplateEditMusicTypeCustom];
    [musicItems addObject:item3];
    
    self.editItems = @[clipItems, textItems, musicItems];
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
    
    self.player = [[AUITemplatePlay alloc] initWithEditor:self.editor];
    [self.player addObserver:self];
    
    [self setupPlayProgressView:CGRectMake(0, self.contentView.av_height - 194 - AVSafeBottom - 44, self.contentView.av_width, 44)];
    [self setupPreviewView:CGRectMake(0, 0, self.contentView.av_width, self.playProgressView.av_top)];
    [self setupEditBar:CGRectMake(0, self.contentView.av_height - 194 - AVSafeBottom, self.contentView.av_width, 194 + AVSafeBottom)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player pause];
}

- (void)setupPreviewView:(CGRect)frame {
    CGSize outputSize = self.editor.currentTemplate.outputSize;
    NSLog(@"AUIVideoTemplateEditor:OutpusSize(%f, %f)", outputSize.width, outputSize.height);
    self.videoPreview = [[AUIVideoPreview alloc] initWithFrame:frame withDisplayResolution:outputSize];
    __weak typeof(self) weakSelf = self;
    self.videoPreview.onFullScreenModeChanged = ^(bool isFull) {
        if (isFull) {
            [weakSelf.editBar clearSelectedNode];
        }
    };
    [self.contentView addSubview:self.videoPreview];
    self.videoPreview.player = self.player;
}

- (void)setupPlayProgressView:(CGRect)frame {
    self.playProgressView = [[AUIVideoPlayProgressView alloc] initWithFrame:frame];
    [self.contentView addSubview:self.playProgressView];
    __weak typeof(self) weakSelf = self;
    self.playProgressView.onFullScreenBtnClicked = ^(BOOL fullScreen){
        [weakSelf.videoPreview enterFullScreen:weakSelf.view];
    };
    self.playProgressView.player = self.player;
}

- (void)setupEditBar:(CGRect)frame {
    __weak typeof(self) weakSelf = self;
    self.editBar = [[AUIVideoTemplateEditBar alloc] initWithFrame:frame editItems:self.editItems];
    self.editBar.selectedAssetBlock = ^(id<AUIVideoTemplateEditItemProtocol>  _Nullable editItem) {
        weakSelf.selectedNodeView.hidden = YES;
        AliyunAETemplateAsset *nativeAsset = editItem.itemMedia.asset ?: editItem.itemText.asset;
        if (!nativeAsset) {
            return;
        }
        [weakSelf seek:nativeAsset];
        if (editItem.itemText) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf drawBox:nativeAsset];
            });
        }
    };
    self.editBar.editAssetBlock = ^(id<AUIVideoTemplateEditItemProtocol>  _Nonnull editItem) {
        [weakSelf.editor commit];
        AliyunAETemplateAsset *nativeAsset = editItem.itemMedia.asset ?: editItem.itemText.asset;
        if (!nativeAsset) {
            return;
        }
        [weakSelf seek:nativeAsset];
        if (editItem.itemText) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf drawBox:nativeAsset];
            });
        }
    };
    self.editBar.selectedMusicBlock = ^(NSString * _Nullable musicPath) {
        [weakSelf.editor replaceAudio:musicPath];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.player play];
        });
    };
    
    self.editBar.player = self.player;
    [self.contentView addSubview:self.editBar];
}

- (void)seek:(AliyunAETemplateAsset *)nativeAsset {
    NSAssert(nativeAsset, @"nativeAsset");
    NSLog(@"select asset: %@", nativeAsset);

    AliyunAETemplateAssetTimeRange *timeRange = nativeAsset.timeRanges.firstObject;
    if (timeRange) {
//        NSTimeInterval startTime = timeRange.timelineIn;
        NSTimeInterval startTime = timeRange.timelineIn + (timeRange.timelineOut - timeRange.timelineIn ) / 2.0;
        [self.player seek:startTime];
    }
    else {
        [self.player pause];
    }
}

- (void)drawBox:(AliyunAETemplateAsset *)nativeAsset {
    NSAssert(nativeAsset, @"nativeAsset");
    if (!self.selectedNodeView) {
        self.selectedNodeView = [[UIView alloc] init];
        [self.videoPreview.displayView addSubview:self.selectedNodeView];
    }
    
    self.selectedNodeView.frame = self.videoPreview.displayView.bounds;
    NSArray<CALayer *> *allLayers = [self.selectedNodeView.layer.sublayers copy];
    [allLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    
    CGSize resolution = self.editor.currentTemplate.outputSize;
    CGSize scale = CGSizeMake(self.selectedNodeView.av_width / resolution.width, self.selectedNodeView.av_height / resolution.height);
#ifdef DrawBoxByEditInfo
    // 绘制设计模板时指定边框
    CALayer *layer = [CALayer layer];
    layer.borderColor = AUIFoundationColor(@"colourful_border_strong").CGColor;
    layer.borderWidth = 2.0;
    [self.selectedNodeView.layer addSublayer:layer];
    layer.bounds = CGRectMake(0, 0, nativeAsset.editRect.size.width, nativeAsset.editRect.size.height);
    layer.anchorPoint = nativeAsset.editAnchor;
    [layer setAffineTransform:CGAffineTransformScale(nativeAsset.editTransform, scale.width, scale.height)];
    layer.position = CGPointMake(nativeAsset.editRect.origin.x * scale.width, nativeAsset.editRect.origin.y * scale.height);
#else
    // 绘制实时渲染计算的边框
    NSArray<AliyunAETemplateAssetVertexs *> *boxVertexs = [self.editor.currentTemplate fetchAssetDrawingVertexs:nativeAsset];
    [boxVertexs enumerateObjectsUsingBlock:^(AliyunAETemplateAssetVertexs * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGPoint tl = obj.tl;
        tl.x = MIN(resolution.width, MAX(0, tl.x)) * scale.width;
        tl.y = MIN(resolution.height, MAX(0, tl.y)) * scale.height;
        
        CGPoint tr = obj.tr;
        tr.x = MIN(resolution.width, MAX(0, tr.x)) * scale.width;
        tr.y = MIN(resolution.height, MAX(0, tr.y)) * scale.height;
        
        CGPoint br = obj.br;
        br.x = MIN(resolution.width, MAX(0, br.x)) * scale.width;
        br.y = MIN(resolution.height, MAX(0, br.y)) * scale.height;
        
        CGPoint bl = obj.bl;
        bl.x = MIN(resolution.width, MAX(0, bl.x)) * scale.width;
        bl.y = MIN(resolution.height, MAX(0, bl.y)) * scale.height;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:tl];
        [path addLineToPoint:tr];
        [path addLineToPoint:br];
        [path addLineToPoint:bl];
        [path closePath];
        
        CAShapeLayer *box = [CAShapeLayer layer];
        box.strokeColor = AUIFoundationColor(@"colourful_border_strong").CGColor;
        box.fillColor = [UIColor clearColor].CGColor;
        box.lineWidth = 2.0;
        box.path = path.CGPath;
        box.frame = self.selectedNodeView.bounds;
        [self.selectedNodeView.layer addSublayer:box];
    }];
#endif
    self.selectedNodeView.hidden = NO;
}


- (void)playStatus:(BOOL)isPlaying {
    if (isPlaying) {
        [self.editBar clearSelectedNode];
    }
}

- (void)onBackBtnClicked:(UIButton *)sender {
    [AVAlertController showWithTitle:@"" message:AUIUgsvGetString(@"确定要放弃编辑中的视频吗？") cancelTitle:AUIFoundationLocalizedString(@"Cancel") okTitle:AUIFoundationLocalizedString(@"OK") onCompleted:^(BOOL isCanced) {
        if (!isCanced) {
            [self goBack];
        }
    }];
}

- (void)onMenuClicked:(UIButton *)sender {
    [self.player stop];
    [self.editBar clearSelectedNode];

    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        
        AUIVideoTemplateExport *export = [[AUIVideoTemplateExport alloc] initWithEditor:self.editor outputParam:self.outputParam];
        export.requestCoverImageBlock = ^(void (^ _Nonnull completedBlock)(UIImage * _Nullable)) {
            if (completedBlock) {
                NSString *path = weakSelf.templateItem.cover;
                if ([path hasPrefix:@"http"]) {
                    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:weakSelf.templateItem.cover] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        completedBlock(image);
                    }];
                }
                else if (path.length > 0) {
                    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Template.bundle" ofType:nil];
                    NSString *local = [bundlePath stringByAppendingPathComponent:path];
                    completedBlock([UIImage imageWithContentsOfFile:local]);
                }
                else {
                    completedBlock(nil);
                }
            }
        };
        
        void (^onFinish)(UIViewController *, NSError *, id) = ^(UIViewController *current, NSError * _Nullable error, id  _Nullable product) {
            if (error) {
                [AVAlertController showWithTitle:AUIUgsvGetString(@"出错了") message:error.description needCancel:NO onCompleted:^(BOOL isCanced) {
                    [current.navigationController popToViewController:weakSelf animated:YES];
                }];
            }
            else {
                [AVAlertController showWithTitle:nil message:AUIUgsvGetString(@"导出成功") needCancel:NO onCompleted:^(BOOL isCanced) {
                    [current.navigationController popToViewController:weakSelf animated:YES];
                }];
            }
        };
        
        UIViewController *pvc = nil;
        if (self.outputParam.needToPublish) {
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

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self.player pause];
}

+ (void)openEditor:(AUIVideoTemplateItem *)templateItem outputParam:(AUIVideoTemplateOutputParam *)param currentVC:(UIViewController *)currentVC {
    if (!templateItem) {
        return;
    }
    
    [AUIVideoTemplateResouce checkResouce:templateItem onVC:currentVC completed:^(NSString * _Nonnull templatePath) {
        NSLog(@"Start edit template with path:%@", templatePath);
        AUIVideoTemplateEditor *editor = [[AUIVideoTemplateEditor alloc] initWithTemplatePath:templatePath];
        editor.templateItem = templateItem;
        editor.outputParam = param;
        
        NSMutableArray *items = @[].mutableCopy;
        [editor.editItems[0] enumerateObjectsUsingBlock:^(AUIVideoTemplateEditItemMedia * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIPhotoPickerInputItem *item = [AUIPhotoPickerInputItem new];
            item.duration = CMTimeMake(obj.asset.duration * 1000, 1000);
            item.filterByDuration = NO;
            item.allowPickingImage = YES;
            item.allowPickingVideo = YES;
            item.extend = obj;
            [items addObject:item];
        }];
        if (items.count == 0) {
            [currentVC.navigationController pushViewController:editor animated:YES];
            return;
        }
        
        AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithInputItems:items];
        [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
            if (results.count > 0) {
                [results enumerateObjectsUsingBlock:^(AUIPhotoPickerResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"Selected file path:%@", obj.filePath);
                    AUIVideoTemplateEditItemMedia *media = (AUIVideoTemplateEditItemMedia *)obj.inputItem.extend;
                    media.pickerResult = obj;
                    [media updateClip:obj.filePath cover:obj.model.thumbnailImage];
                }];

                [sender dismissViewControllerAnimated:NO completion:^{
                    [currentVC.navigationController pushViewController:editor animated:YES];
                }];
            }
        } withOutputDir:[AUIUgsvPath cacheDir]];
        [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
    }];
}

@end
