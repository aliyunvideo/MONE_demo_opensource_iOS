//
//  AUIVideoEditor.m
//  AlivcUGC_Demo
//
//  Created by Bingo on 2022/5/23.
//

#import "AUIVideoEditor.h"
#import "AUIVideoPreview.h"
#import "AUIVideoPlayTimeView.h"
#import "AUIEditorPlay.h"

#import "AUIUgsvMacro.h"
#import "AUIUgsvPath.h"
#import "AVAsset+UgsvHelper.h"

#import "AUIEditorMenuBar.h"
#import "AUIEditorVideoEditBar.h"
#import "AUIEditorCaptionEditBar.h"
#import "AUIEditorStickerEditBar.h"
#import "AUIEditorFilterEditBar.h"
#import "AUIEditorEffectEditBar.h"

#import "AUIVideoEditorExport.h"
#import "AUIMediaPublisher.h"
#import "AUIEditorSelectionPreview.h"


@interface AUIVideoEditor () <AUIEditorActionOperator, AUIEditorActionObserver, AUIEditorSelectionObserver,AUIVideoPlayObserver,UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSString *taskPath;
@property (nonatomic, assign) BOOL isError;

@property (nonatomic, strong) AliyunEditor *aliyunEditor;
@property (nonatomic, strong) AUIEditorPlay *player;
@property (nonatomic, strong) AUIEditorActionManager *actionManager;
@property (nonatomic, strong) AUIEditorSelectionManager *selectionManager;

@property (nonatomic, strong) AUIVideoPreview *videoPreview;
@property (nonatomic, strong) AUIVideoPlayTimeView *playTimeView;
@property (nonatomic, strong) AUIEditorMenuBar *menuBar;
@property (nonatomic, strong) AUIEditorEditBar *editBar;
@property (nonatomic, strong) AUIEditorThumbnailCache *editBarThumbnailCache;

@property (nonatomic, copy) NSString *outputFilePath;

@property (nonatomic, strong) NSMutableDictionary *associatedObjectMap;
@end

@implementation AUIVideoEditor

- (void)dealloc {    
    [self.associatedObjectMap removeAllObjects];
    self.associatedObjectMap = nil;
}

- (instancetype)initWithTaskPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.taskPath = path;
    }
    return self;
}

- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath {
    NSURL *sourceURL = [NSURL fileURLWithPath:videoFilePath];
    AVAsset *videoAsset = [AVAsset assetWithURL:sourceURL];
    if (!videoAsset) {
        return nil;
    }
    CGSize resolution = [videoAsset ugsv_getResolution];
    if (CGSizeEqualToSize(resolution, CGSizeZero)) {
        return nil;
    }
    AliyunClip *clip = [[AliyunClip alloc] initWithVideoPath:videoFilePath animDuration:0];
    self = [self initWithClips:@[clip] withParam:[[AUIVideoOutputParam alloc] initWithOutputSize:resolution]];
    if (self) {
        self.outputFilePath = videoFilePath;
    }
    return self;
}

- (instancetype)initWithClips:(NSArray<AliyunClip *> *)clips withParam:(AUIVideoOutputParam *)param {
    
    if (param && param.outputSizeType == AUIVideoOutputSizeTypeOriginal) {
        AliyunClip *clip = clips.firstObject;
        if (clip) {
            param = [[AUIVideoOutputParam alloc] initWithOutputSize:CGSizeMake(clip.mediaWidth, clip.mediaHeight) withAliyunVideoParam:param];
        }
        else {
            param = [[AUIVideoOutputParam alloc] initWithOutputSize:CGSizeMake(720, 1280) withAliyunVideoParam:param];
        }
    }
    
    NSString *taskPath = [AUIUgsvPath editorTaskPath:YES];
    AliyunImporter *importer =[[AliyunImporter alloc] initWithPath:taskPath outputSize:param.outputSize];
    [clips enumerateObjectsUsingBlock:^(AliyunClip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [importer addMediaClip:obj];
    }];
    [importer setVideoParam:param];
    [importer generateProjectConfigure];
    
    return [self initWithTaskPath:taskPath];
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
    
    [self setupMenuBar:CGRectMake(0, self.contentView.av_height - 114 - AVSafeBottom, self.contentView.av_width, 114 + AVSafeBottom)];
    [self setupPlayTimeView:CGRectMake(0, self.menuBar.av_top - 42, self.contentView.av_width, 42)];
    [self setupPreviewView:CGRectMake(0, 0, self.contentView.av_width, self.playTimeView.av_top)];
    
    [self setupEditorProject];
    [self.player addObserver:self];
    [self.player play];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isError) {
        [AVAlertController showWithTitle:nil message:AUIUgsvGetString(@"出错了！") needCancel:NO onCompleted:^(BOOL isCanced) {
            [self goBack];
        }];
    }
    
    [self.aliyunEditor startEdit];
    [self tryCaptureScreen];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.aliyunEditor stopEdit];
}

- (void)setupEditorProject {
    
    self.aliyunEditor = [[AliyunEditor alloc] initWithPath:self.taskPath preview:self.videoPreview.displayView];
    self.aliyunEditor.renderWrapper.renderMode = AliyunEditorRenderViewModeResizeAspect;
    if (!self.aliyunEditor) {
        self.isError = YES;
        return;
    }
    int ret = [self.aliyunEditor startEdit];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        self.isError = YES;
        return;
    }
    self.videoPreview.displayResolution = self.aliyunEditor.getEditorProject.config.outputResolution;
    
    self.player = [[AUIEditorPlay alloc] initWithEditor:self.aliyunEditor.getPlayer];
    self.player.isLoopPlay = YES;
    
    self.videoPreview.player = self.player;
    self.playTimeView.player = self.player;
    
    self.actionManager = [[AUIEditorActionManager alloc] init];
    self.actionManager.currentOperator = self;
    [self.actionManager addObserver:self];
    self.menuBar.actionManager = self.actionManager;
    
    self.selectionManager = [[AUIEditorSelectionManager alloc] initWithActionManager:self.actionManager];
    self.selectionManager.selectionPreviewSuperView = self.videoPreview.displayView;
    [self.selectionManager addObserver:self];
    self.menuBar.selectionManager = self.selectionManager;
}

- (void)setupPreviewView:(CGRect)frame {
    self.videoPreview = [[AUIVideoPreview alloc] initWithFrame:frame];
    
    __weak typeof(self) weakSelf = self;
    self.videoPreview.onFullScreenModeChanged = ^(bool isFull) {
        weakSelf.selectionManager.enableSelectionPreview = !isFull;
        [weakSelf markEditorNeedUpdatePlayTime];
        if (isFull) {
            if ([weakSelf.editBar isKindOfClass:AUIEditorCaptionEditBar.class]) {
                 [(AUIEditorCaptionEditBar *)weakSelf.editBar textViewResignFirstResponder];
            }
        }
    };
    self.videoPreview.onDisplayViewLayoutChanged = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.selectionManager.currentSelectionPreview updateLayout];
        });
    };
    
    UITapGestureRecognizer *tapGesture =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPreviewClicked:)];
    tapGesture.delegate = self;
    [self.videoPreview addGestureRecognizer:tapGesture];
    [self.contentView addSubview:self.videoPreview];
    [self.contentView insertSubview:self.playTimeView aboveSubview:self.videoPreview];
}

- (void)setupPlayTimeView:(CGRect)frame {
    self.playTimeView = [[AUIVideoPlayTimeView alloc] initWithFrame:frame];
    [self.contentView addSubview:self.playTimeView];
    __weak typeof(self) weakSelf = self;
    self.playTimeView.onEnterFullScreenClicked = ^{
        [weakSelf.videoPreview enterFullScreen:weakSelf.view];
    };
}

- (void)setupMenuBar:(CGRect)frame {
    self.menuBar = [[AUIEditorMenuBar alloc] initWithFrame:frame];
    [self.contentView addSubview:self.menuBar];
}

- (void)showEditBar:(AUIEditorEditBar *)editBar {
    if (self.editBar) {
        if ([self.editBar isKindOfClass:editBar.class]) {
            return;
        }
        [self hideEditBar];
    }
    
    if (!self.editBarThumbnailCache) {
        self.editBarThumbnailCache = [AUIEditorThumbnailCache new];
    }
    
    self.editBar = editBar;
    self.editBar.actionManager = self.actionManager;
    self.editBar.selectionManager = self.selectionManager;
    self.editBar.thumbnailCache = self.editBarThumbnailCache;
    [self.editBar barWillAppear];
    [self.contentView addSubview:self.editBar];
    
    self.playTimeView.frame = CGRectMake(0, self.editBar.av_top - 42, self.contentView.av_width, 42);
    self.videoPreview.frame = CGRectMake(0, 0, self.contentView.av_width, self.playTimeView.av_top);
}

- (void)hideEditBar {
    if (self.editBar) {
        [self.editBar barWillDisappear];
        self.editBar.thumbnailCache = nil;
        self.editBar.actionManager = nil;
        self.editBar.selectionManager = nil;
        [self.editBar removeFromSuperview];
        self.editBar = nil;
        
        self.playTimeView.frame = CGRectMake(0, self.menuBar.av_top - 42, self.contentView.av_width, 42);
        self.videoPreview.frame = CGRectMake(0, 0, self.contentView.av_width, self.playTimeView.av_top);
    }
}

- (void)onPreviewClicked:(UITapGestureRecognizer *)recognizer {
    CGPoint displayClickPoint = [recognizer locationInView:self.videoPreview.displayView];
    if ([self.selectionManager selectFromDisplayViewPosition:displayClickPoint]) {
        return;
    }
    [self hideEditBar];
}

- (UIImage *)tryCaptureScreen {
    UIImage *cover = [self.actionManager.currentOperator associatedObjectForKey:@"cover"];
    if (!cover) {
        cover = [self.player screenCapture];
        if (cover) {
            [self.actionManager.currentOperator setAssociatedObject:cover forKey:@"cover"];
        }
    }
    return cover;
}

- (void)onMenuClicked:(UIButton *)sender {
    [self.player seek:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak typeof(self) weakSelf = self;

        AUIVideoEditorExport *export = nil;
        if (self.outputFilePath) {
            // Not changed
            export = [[AUIVideoEditorExport alloc] initWithVideoFilePath:self.outputFilePath outputSize:self.aliyunEditor.getEditorProject.config.outputResolution];
        }
        else {
            export = [[AUIVideoEditorExport alloc] initWithTaskPath:self.taskPath];
        }
        
        export.saveToAlbumExportCompleted = self.saveToAlbumExportCompleted;
        export.requestCoverImageBlock = ^(void (^ _Nonnull completedBlock)(UIImage * _Nonnull)) {
            UIImage *cover = [weakSelf tryCaptureScreen];
            if (completedBlock) {
                completedBlock(cover);
            }
        };
        
        UIViewController *pvc = nil;
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

#pragma mark - AUIEditorActionObserver

- (void)actionItem:(AUIEditorActionItem *)item doActionResult:(NSError *)error retObject:(id)retObject {
    if (error) {
        return;
    }
}

- (void)selectionManager:(AUIEditorSelectionManager *)manger didSelected:(AUIEditorSelectionObject *)selectionObject {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (selectionObject.type == AUIEditorSelectionObjectTypeText) {
            [self enterCaptionMode];
        }
        else if (selectionObject.type == AUIEditorSelectionObjectTypeSticker) {
            [self enterStickerMode];
        }
    });
}

#pragma mark - AUIEditorActionOperator

- (UIViewController *)currentVC {
    return self;
}

- (AliyunEditor *)currentEditor {
    return self.aliyunEditor;
}

- (AUIEditorPlay *)currentPlayer {
    return self.player;
}

- (id)associatedObjectForKey:(NSString *)key {
    return [self.associatedObjectMap objectForKey:key];
}

- (void)setAssociatedObject:(id)object forKey:(NSString *)key {
    if (!self.associatedObjectMap) {
        self.associatedObjectMap = [NSMutableDictionary dictionary];
    }
    if (object) {
        [self.associatedObjectMap setObject:object forKey:key];
    }
    else {
        [self.associatedObjectMap removeObjectForKey:key];
    }
}

- (void)enterVideoMode {
    CGFloat ph = [AUIEditorVideoEditBar contentHeight] + AVSafeBottom;
    AUIEditorEditBar *editBar = [[AUIEditorVideoEditBar alloc] initWithFrame:CGRectMake(0, self.contentView.av_height - ph, self.contentView.av_width, ph)];
    [self showEditBar:editBar];
}

- (void)enterCaptionMode {
    CGFloat ph = [AUIEditorCaptionEditBar contentHeight] + AVSafeBottom;
    AUIEditorCaptionEditBar *editBar = [[AUIEditorCaptionEditBar alloc] initWithFrame:CGRectMake(0, self.contentView.av_height - ph, self.contentView.av_width, ph)];
    [self showEditBar:editBar];
    __weak typeof(self) weakSelf = self;
    editBar.onKeyboardShowChanged = ^(bool show, CGFloat originY) {
        
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.playTimeView.av_bottom = originY - self.headerView.av_bottom;
        }];
      
    };
}

- (void)enterStickerMode {
    CGFloat ph = [AUIEditorStickerEditBar contentHeight] + AVSafeBottom;
    AUIEditorEditBar *editBar = [[AUIEditorStickerEditBar alloc] initWithFrame:CGRectMake(0, self.contentView.av_height - ph, self.contentView.av_width, ph)];
    [self showEditBar:editBar];
}

- (void)enterFilterMode {
    CGFloat ph = [AUIEditorFilterEditBar contentHeight] + AVSafeBottom;
    AUIEditorEditBar *editBar = [[AUIEditorFilterEditBar alloc] initWithFrame:CGRectMake(0, self.contentView.av_height - ph, self.contentView.av_width, ph)];
    [self showEditBar:editBar];
}

- (void)enterEffectMode {
    CGFloat ph = [AUIEditorEffectEditBar contentHeight] + AVSafeBottom;
    AUIEditorEditBar *editBar = [[AUIEditorEffectEditBar alloc] initWithFrame:CGRectMake(0, self.contentView.av_height - ph, self.contentView.av_width, ph)];
    [self showEditBar:editBar];
}

- (void)markEditorProjectChanged {
    self.outputFilePath = nil;
}

- (void)markEditorNeedUpdatePlayTime {
    [self.editBar refreshPlayTime];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return  ![touch.view isDescendantOfView:self.selectionManager.currentSelectionPreview];
}

@end
