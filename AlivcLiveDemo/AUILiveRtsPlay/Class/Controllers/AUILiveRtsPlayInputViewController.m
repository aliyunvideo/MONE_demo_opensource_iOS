//
//  AUILiveRtsPlayInputViewController.m
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/11/15.
//

#import "AUILiveRtsPlayInputViewController.h"
#import "AUILiveRtsPlayInputUrlView.h"
#import "AUILiveRtsPlayPullViewController.h"

@interface AUILiveRtsPlayInputViewController ()

@property (nonatomic, strong) AUILiveRtsPlayInputUrlView *urlInputView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) NSString *playUrl;

@end

@implementation AUILiveRtsPlayInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.text = AUILiveRtsPlayString(@"超低延时直播");
    self.hiddenMenuButton = YES;
    
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshStartButton];
}

- (void)setupContent {
    __weak typeof(self) weakSelf = self;
    self.urlInputView.placeholder = AUILiveRtsPlayString(@"请输入RTS超低延时播放地址");
    self.urlInputView.inputChanged = ^(NSString * _Nonnull value) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.playUrl = value;
        [strongSelf updateStartButtonEnableStatus:value.length > 0];
    };
    [self.contentView addSubview:self.urlInputView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = AUILiveRtsPlayString(@"播放地址可到视频直播控制台用地址生成器生成");
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 0;
    tipLabel.font = AVGetRegularFont(12);
    tipLabel.textColor = AUIFoundationColor(@"text_weak");
    
    CGFloat tipLabelWidth = self.contentView.av_width - 16 * 2;
    CGSize tipLabelSize = [tipLabel sizeThatFits:CGSizeMake(tipLabelWidth, MAXFLOAT)];
    tipLabel.frame = CGRectMake(16, self.urlInputView.av_bottom + 110, tipLabelWidth, tipLabelSize.height);
    
    [self.contentView addSubview:tipLabel];
    
    self.startButton.frame = CGRectMake(46, tipLabel.av_bottom + 12, self.contentView.av_width - 46 * 2, 48);
    [self.contentView addSubview:self.startButton];
}

- (void)updateStartButtonEnableStatus:(BOOL)enable {
    self.startButton.enabled = enable;
    if (enable) {
        [self.startButton setBackgroundColor:AUILiveRtsPlayColor(@"rp_startbtn_select")];
        [self.startButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    } else {
        [self.startButton setBackgroundColor:AUILiveRtsPlayColor(@"rp_startbtn_unselect")];
        [self.startButton setTitleColor:AUIFoundationColor(@"text_ultraweak") forState:UIControlStateNormal];
    }
}

- (void)clickStartButton:(UIButton *)sender {
    AUILiveRtsPlayPullViewController *vc = [[AUILiveRtsPlayPullViewController alloc] init];
    vc.playUrl = self.playUrl;
    [self.navigationController pushViewController:vc animated:YES];
    
    [self updateStartButtonEnableStatus:NO];
}

- (void)refreshStartButton {
    if (self.playUrl.length > 0) {
        [self updateStartButtonEnableStatus:YES];
    } else {
        [self updateStartButtonEnableStatus:NO];
    }
}

#pragma mark -- lazy load
- (AUILiveRtsPlayInputUrlView *)urlInputView {
    if (!_urlInputView) {
        _urlInputView = [[AUILiveRtsPlayInputUrlView alloc] initWithFrame:CGRectMake(20, 30, self.contentView.av_width - 20 * 2, 73) sourceVC:self];
        _urlInputView.themeName = AUILiveRtsPlayString(@"播放地址");
    }
    return _urlInputView;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_startButton setBackgroundColor:AUILiveRtsPlayColor(@"rp_startbtn_unselect")];
        [_startButton setTitle:AUILiveRtsPlayString(@"开始播放") forState:UIControlStateNormal];
        [_startButton setTitleColor:AUIFoundationColor(@"text_ultraweak") forState:UIControlStateNormal];
        [_startButton.titleLabel setFont:AVGetRegularFont(18)];
        [_startButton.layer setMasksToBounds:YES];
        [_startButton.layer setCornerRadius:24];
        [_startButton addTarget:self action:@selector(clickStartButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

@end
