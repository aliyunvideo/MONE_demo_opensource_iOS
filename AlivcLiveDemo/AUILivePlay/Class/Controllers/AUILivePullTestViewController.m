//
//  AUILivePullTestViewController.m
//  AliLiveSdk-Demo
//
//  Created by BOTAO on 2020/12/17.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "AUILivePullTestViewController.h"
#import "AUILiveQRCodeViewController.h"
#import "Masonry.h"
#import "AUILiveMonitorView.h"
#import "AUILivePullPlayActionView.h"

@interface AUILivePullTestViewController ()<AVPDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) AliPlayer *player;
@property (nonatomic, strong) NSString *playurl;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UIView *searchLine;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *pullButton;
@property (nonatomic, strong) AUILiveMonitorView *monitorView;
@property (nonatomic, strong) AUILivePullPlayActionView *footerPlayActionView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isScan;

@end

@implementation AUILivePullTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = AUIFoundationColor(@"bg_weak");
    [self setupHeaderViews];
    [self setupViews];
    [self setupSearchView];
    [self addNotifications];
}

- (void)setupHeaderViews {
    [self updateBackButtonWithPlaying:NO];
    self.hiddenMenuButton = YES;
    self.headerLineView.hidden = NO;
    self.headerLineView.backgroundColor = AUIFoundationColor(@"fill_weak");
    self.headerLineView.av_height = 0.5;
    self.titleView.text = AUILivePlayString(@"拉流播放");
    [self.view bringSubviewToFront:self.headerView];
}

- (void)updateBackButtonWithPlaying:(BOOL)playing {
    if (playing) {
        [self.backButton setImage:AUIFoundationImage(@"ic_close") forState:UIControlStateNormal];
    } else {
        [self.backButton setImage:AUIFoundationImage(@"ic_back") forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.isScan) {
        [self.player stop];
        [self.player destroy];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)dealloc {
    if (self.player.rate > 0) {
        [self.player stop];
    }
    [self.player destroy];
}

- (void)setupViews {
    // 播放view
    
    // 背景图片
    UIImageView *imageView = [[UIImageView alloc] initWithImage:AUILiveCommonImage(@"camera_push_bgm_bgImage")];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.renderView = [[UIView alloc] init];
    [self.view addSubview:self.renderView];
    [self.view insertSubview:self.renderView aboveSubview:imageView];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 监控数据view
     _monitorView = [[AUILiveMonitorView alloc] initWithFrame:CGRectMake(10, 130, self.view.frame.size.width - 20, 150)];
     _monitorView.backgroundColor = [UIColor clearColor];
     [self.view addSubview:_monitorView];
    _monitorView.hidden = YES;
    
    self.footerPlayActionView = [[AUILivePullPlayActionView alloc] init];
    [self.view addSubview:self.footerPlayActionView];
    [self.footerPlayActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.equalTo(self.view).mas_offset(-36);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(84);
    }];
    self.footerPlayActionView.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    self.footerPlayActionView.stopPlayAction = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf didSelectStopWatch];
    };
    self.footerPlayActionView.mutedAction = ^(BOOL muted) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf didSelectMuted:muted];
    };
    self.footerPlayActionView.dataIndicatorAction = ^{
        
    };
}

// 扫描框
- (void)setupSearchView {
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)];
    [self.view addGestureRecognizer:self.tap];
    
    UIView *searchView = [[UIView alloc] init];
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@36);
        make.top.equalTo(self.headerLineView.mas_bottom).offset(20);
    }];
    searchView.layer.cornerRadius = 18;
    searchView.layer.masksToBounds = YES;
    searchView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.searchView = searchView;
    
    UIButton *scanButton = [[UIButton alloc] init];
    [searchView addSubview:scanButton];
    [scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView).offset(18);
        make.centerY.equalTo(searchView);
        make.width.height.equalTo(@20);
    }];
    [scanButton setImage:AUILiveCommonImage(@"ic_scan") forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanUrl) forControlEvents:UIControlEventTouchUpInside];
    self.scanButton = scanButton;
    
    UIView *line = [[UIView alloc] init];
    [searchView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scanButton.mas_right).offset(8);
        make.centerY.equalTo(scanButton);
        make.height.equalTo(@20);
        make.width.equalTo(@1);
    }];
    line.backgroundColor = AUILivePlayColor(@"ir_pull_headerline");
    self.searchLine = line;
    
    UITextField *textField = [[UITextField alloc] init];
    [searchView addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(line.mas_right).offset(8);
        make.centerY.equalTo(searchView);
        make.top.bottom.equalTo(searchView);
        make.right.equalTo(searchView).offset(-100);
    }];
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = [UIColor whiteColor];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = [UIFont systemFontOfSize:16];
    textField.tintColor = [UIColor whiteColor];
    textField.keyboardType = UIKeyboardTypeURL;
    self.textField = textField;
    [self updateTextFieldPlayerholder:AUILivePlayString(@"输入拉流url")];
    
    UIButton *pullButton = [[UIButton alloc] init];
    pullButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
    [pullButton setTitle:AUILivePlayString(@"拉流") forState:UIControlStateNormal];
    [pullButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pullButton.titleLabel.font = AVGetRegularFont(17);
    pullButton.layer.cornerRadius = 18.f;
    pullButton.layer.masksToBounds = YES;
    [searchView addSubview:pullButton];
    [pullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(searchView);
        make.centerY.equalTo(searchView);
        make.width.equalTo(@64);
        make.height.equalTo(@36);
    }];
    [pullButton addTarget:self action:@selector(startPull) forControlEvents:UIControlEventTouchUpInside];
    self.pullButton = pullButton;
    [self.view layoutIfNeeded];
}

- (void)updateSearchViewBaseKeyboardTop:(CGFloat)keyboardTop {
    if (self.isEditing) {
        self.scanButton.hidden = YES;
        self.searchLine.hidden = YES;
        [self updateTextFieldPlayerholder:AUILivePlayString(@"搜索或输入网址")];
        
        self.pullButton.backgroundColor = self.textField.backgroundColor;
        [self.pullButton setTitle:AUILiveCommonString(@"取消") forState:UIControlStateNormal];
        [self.pullButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        
        [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.height.equalTo(@36);
            make.top.mas_equalTo(keyboardTop-10-36);
        }];
        
        [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchView).offset(18);
            make.centerY.equalTo(self.searchView);
            make.top.bottom.equalTo(self.searchView);
            make.right.equalTo(self.searchView).offset(-100);
        }];
    } else {
        self.scanButton.hidden = NO;
        self.searchLine.hidden = NO;
        [self updateTextFieldPlayerholder:AUILivePlayString(@"输入拉流url")];
        
        self.pullButton.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
        [self.pullButton setTitle:AUILivePlayString(@"拉流") forState:UIControlStateNormal];
        [self.pullButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.height.equalTo(@36);
            make.top.equalTo(self.headerLineView.mas_bottom).offset(20);
        }];
        [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchLine.mas_right).offset(8);
            make.centerY.equalTo(self.searchView);
            make.top.bottom.equalTo(self.searchView);
            make.right.equalTo(self.searchView).offset(-100);
        }];
    }
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)createPlayerAndPlay {
    self.player = [[AliPlayer alloc] init];
    //先获取配置
    AVPConfig *config = [self.player getConfig];
    if([self.playurl hasPrefix:@"artc://"]){
        //设置最大延迟为1000，延迟控制交由RTS控制
        config.maxDelayTime = 1000;
        //设置播放器启播缓存为10ms，数据控制由RTS控制。
        config.highBufferDuration = 10;
        config.startBufferDuration = 10;
    }
    else
    {
        config.maxDelayTime = 10000;
        config.highBufferDuration = 100;
        config.startBufferDuration = 100;
    }
    [self.player setConfig:config];
    
    self.player.autoPlay = YES;
    self.player.delegate = self;
    self.player.playerView = self.renderView;
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:self.playurl];
    [self.player setUrlSource:source];
    [self.player prepare];
    
    // 开启播放器日志
    if (![self.playurl hasPrefix:@"rtmp://"]) {
        [AliPlayer setEnableLog:YES];
        [AliPlayer setLogCallbackInfo:LOG_LEVEL_TRACE callbackBlock:^(AVPLogLevel logLevel,NSString* strLog){
            [AliveLiveDemoUtil writeLogMessageToLocationFile:strLog isCover:NO];
        }];
    }
}

- (void)clickBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startPull {
    if (!self.isEditing) {
        self.playurl = self.textField.text;
        if (self.playurl == nil || self.playurl.length == 0) {
            [AVToastView show:AUILivePlayString(@"无效的URL") view:self.view position:AVToastViewPositionMid];
            return;
        }
        [AVToastView show:AUILivePlayString(@"开始拉流") view:self.view position:AVToastViewPositionMid];
        [self createPlayerAndPlay];
    } else {
        [self.textField resignFirstResponder];
    }
}

- (void)stopPull {
    [self.player stop];
    [self updateBackButtonWithPlaying:NO];
    self.footerPlayActionView.hidden = YES;
    [self.view addGestureRecognizer:self.tap];
}

- (void)scanUrl {
    AUILiveQRCodeViewController *QRController = [[AUILiveQRCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    QRController.backValueBlock = ^(BOOL scaned, NSString *sweepString) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.isScan = NO;
        [strongSelf.textField resignFirstResponder];
        if (scaned) {
            strongSelf.playurl = sweepString;
            if (sweepString) {
                strongSelf.textField.text = sweepString;
            }
        }
    };
    [self.navigationController pushViewController:QRController animated:YES];
    self.isScan = YES;
}

- (void)inputUrl {
    __weak typeof(self) weakSelf = self;
    [AVAlertController showInput:AUILivePlayString(@"输入URL") vc:self onCompleted:^(NSString * _Nonnull input) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.textField.text = [NSString stringWithFormat:@"%@", input];
        strongSelf.playurl = input;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *url = textField.text ?:@"";
    if (url.length == 0) {
        [AVToastView show:AUILivePlayString(@"无效的URL") view:self.view position:AVToastViewPositionMid];
        return NO;
    }
    self.playurl = textField.text ?:@"";
    [self startPull];
    [textField resignFirstResponder];
    return YES;
}

- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    if (eventType == AVPEventPrepareDone) {
        [self.view removeGestureRecognizer:self.tap];
        [self updateBackButtonWithPlaying:YES];
        self.footerPlayActionView.hidden = NO;
        self.footerPlayActionView.muted = player.muted;
    }
}

- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    [AVToastView show:errorModel.message view:self.view position:AVToastViewPositionMid];
    [self stopPull];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player prepare];
    });
}

- (void)updateTextFieldPlayerholder:(NSString *)playerholder {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:playerholder attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:self.textField.font}];
    self.textField.attributedPlaceholder = attrString;
}

- (void)didSelectStopWatch {
    [self stopPull];
    [self.player destroy];
}

- (void)didSelectMuted:(BOOL)muted {
    if (muted) {
        self.player.muted = YES;
    } else {
        self.player.muted = NO;
    }
}

- (void)didSelectDataIndicators {
    self.monitorView.hidden =  !self.monitorView.hidden;
}

- (void)keyboardWillShow:(NSNotification *)sender {
    CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.isEditing = YES;
    [UIView animateWithDuration:0.2f animations:^{
        [self updateSearchViewBaseKeyboardTop:keyboardFrame.origin.y];
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.isEditing = NO;
    [UIView animateWithDuration:0.2f animations:^{
        [self updateSearchViewBaseKeyboardTop:0];
    }];
}

/**
 * @brief 本地视频统计信息(2s触发一次)
 * @param localVideoStats 本地视频统计信息
 * @note SDK每两秒触发一次此统计信息回调
 */
/*
- (void)onLiveLocalVideoStats:(AliLiveEngine *)publisher stats:(AliLiveLocalVideoStats *)localVideoStats{
    __weak AUILivePullTestViewController *wkSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO 12.30
//        if (wkSelf.monitorView.hidden) {
//            wkSelf.monitorView.hidden = NO;
//        }
        wkSelf.monitorView.hidden = YES;
        wkSelf.monitorView.titleLabel.text = @"本地视频统计信息";
        wkSelf.monitorView.sentBitrateLabel.text = [NSString stringWithFormat:@"发送码率： %d kbps", (int)localVideoStats.sentBitrate/1000];
        wkSelf.monitorView.sentFpsLabel.text = [NSString stringWithFormat:@"发送帧率：%d fps",localVideoStats.sentFps];
        wkSelf.monitorView.encodeFpsLabel.text = [NSString stringWithFormat:@"编码帧率：%d",localVideoStats.encodeFps];
    });
}
*/


- (void)touchAction {
    [self.textField resignFirstResponder];
}
@end
