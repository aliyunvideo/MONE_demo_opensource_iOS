//
//  AUILivePushReplayKitTipViewController.m
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/4.
//

#import "AUILivePushReplayKitTipViewController.h"
#import "AUILivePushReplayKitConfigViewController.h"

#pragma mark -- AUILivePushReplayKitTipProgress
@interface AUILivePushReplayKitTipProgress : UIView
@end
@implementation AUILivePushReplayKitTipProgress

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2.0 - 1, 0, 2, frame.size.height)];
        line.backgroundColor = AUILiveCommonColor(@"ir_sheet_button");
        [self addSubview:line];
        
        UIButton *oneBtn = [self getProgressButtonWithName:@"1" frame:CGRectMake(0, 0, 24, 24)];
        [self addSubview:oneBtn];
        
        UIButton *twoBtn = [self getProgressButtonWithName:@"2" frame:CGRectMake(0, oneBtn.av_bottom + 60, 24, 24)];
        [self addSubview:twoBtn];
        
        UIButton *threeBtn = [self getProgressButtonWithName:@"3" frame:CGRectMake(0, twoBtn.av_bottom + 60, 24, 24)];
        [self addSubview:threeBtn];
    }
    return self;
}

- (UIButton *)getProgressButtonWithName:(NSString *)name frame:(CGRect)frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = AUILiveCommonColor(@"ir_sheet_button");
    btn.layer.cornerRadius = frame.size.width / 2.0;
    [btn setTitle:name forState:UIControlStateNormal];
    // btn.titleLabel.font = AVGetRegularFont(14);
    [btn setTitleColor:AUILiveRecordPushColor(@"ir_button_text") forState:UIControlStateNormal];
    return btn;
}

@end

#pragma mark -- AUILivePushReplayKitTipViewController
@interface AUILivePushReplayKitTipViewController ()

@end

@implementation AUILivePushReplayKitTipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView.hidden = YES;
    self.contentView.av_top = 0;
    self.contentView.av_height += self.headerView.av_height;
    self.contentView.backgroundColor = AUILiveRecordPushColor(@"ir_content_bg");
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(42, 140, self.view.av_width - 42 * 2, self.view.av_height - 140 * 2)];
    tipView.backgroundColor = AUIFoundationColor(@"bg_weak");
    [self.view addSubview:tipView];
    
    UILabel *tipHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, tipView.av_width, 23)];
    tipHeaderLabel.text = AUILiveRecordPushString(@"录屏使用说明");
    tipHeaderLabel.textAlignment = NSTextAlignmentCenter;
    tipHeaderLabel.textColor = AUIFoundationColor(@"text_strong");
    tipHeaderLabel.font = AVGetRegularFont(17);
    [tipView addSubview:tipHeaderLabel];
    
    UIView *progressTipView = [[UIView alloc] initWithFrame:CGRectMake(24, tipHeaderLabel.av_bottom + 24, tipView.av_width - 24 * 2, 192)];
    [tipView addSubview:progressTipView];
    
    AUILivePushReplayKitTipProgress *tipProgress = [[AUILivePushReplayKitTipProgress alloc] initWithFrame:CGRectMake(24, 0, 24, progressTipView.av_height)];
    [progressTipView addSubview:tipProgress];
    
    UILabel *oneProgressText = [self getProgressText:@"请先到控制中心，长按启动系统屏幕录制" frame:CGRectMake(tipProgress.av_right + 16, 0, progressTipView.av_width - tipProgress.av_right - 16, 40)];
    [progressTipView addSubview:oneProgressText];
    
    UILabel *oneProgressSubText = [self getSubText:@"若无此选项请从设置中的控制中心里添加" frame:CGRectMake(tipProgress.av_right + 16, oneProgressText.av_bottom + 3, progressTipView.av_width - tipProgress.av_right - 16, 24) textColor:AUIFoundationColor(@"text_weak")];
    [progressTipView addSubview:oneProgressSubText];
    
    UILabel *twoProgressText = [self getProgressText:@"选择AlivcLiveBroadcast" frame:CGRectMake(tipProgress.av_right + 16, 60 + 24, progressTipView.av_width - tipProgress.av_right - 16, 24)];
    [progressTipView addSubview:twoProgressText];
    
    UILabel *threeProgressText = [self getProgressText:@"请先到控制中心，长按启动系统屏幕录制" frame:CGRectMake(tipProgress.av_right + 16, 60 * 2 + 24 * 2, progressTipView.av_width - tipProgress.av_right - 16, 40)];
    [progressTipView addSubview:threeProgressText];
    
    UIView *warningTipView = [[UIView alloc] initWithFrame:CGRectMake(24, progressTipView.av_bottom + 18, tipView.av_width - 24 * 2, 133)];
    [tipView addSubview:warningTipView];
    
    UILabel *warningTopLabel = [self getSubText:AUILiveRecordPushString(@"注意：以上设置仅载开始推流前有效，推流后改变设置无效") frame:CGRectMake(18, 0, warningTipView.av_width - 18 * 2, 35) textColor: AUIFoundationColor(@"text_strong")];
    [warningTipView addSubview:warningTopLabel];
    
    UILabel *warningBottomLabel = [self getSubText:AUILiveRecordPushString(@"iOS13系统由于剪切板限制，无法向extension传递配置信息。请修改SampleHandler.m源码中的配置信息，实现录屏演示。") frame:CGRectMake(18, warningTopLabel.av_bottom + 8, warningTipView.av_width - 18 * 2, 68) textColor: AUIFoundationColor(@"text_weak")];
    [warningTipView addSubview:warningBottomLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, tipView.av_height - 15 - 21, tipView.av_width, 21);
    [closeBtn setTitle:AUILiveRecordPushString(@"知道了") forState:UIControlStateNormal];
    [closeBtn setTitleColor:AUILiveCommonColor(@"ir_sheet_button") forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:closeBtn];
}

- (void)dismiss {
    AUILivePushReplayKitConfigViewController *configVC = [[AUILivePushReplayKitConfigViewController alloc] init];
    
    if (self.presentingViewController) {
        __block AVNavigationController *presentingViewController = (AVNavigationController *)self.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^{
            [presentingViewController pushViewController:configVC animated:YES];
        }];
    } else {
        configVC.hiddenBackButton = YES;
        AVNavigationController *nav = [[AVNavigationController alloc]initWithRootViewController:configVC];
        [[[UIApplication sharedApplication] delegate].window setRootViewController:nav];
    }
    
    if ([AUILiveRecordPushManager isTipPageShow]) {
        [AUILiveRecordPushManager updateTipPageShow:NO];
    }
}

- (UILabel *)getProgressText:(NSString *)text frame:(CGRect)frame {
    UILabel *progressText = [[UILabel alloc] initWithFrame:frame];
    progressText.textColor = AUIFoundationColor(@"text_strong");
    progressText.font = AVGetRegularFont(14);
    progressText.numberOfLines = 0;
    progressText.text = AUILiveRecordPushString(text);
    return progressText;
}

- (UILabel *)getSubText:(NSString *)text frame:(CGRect)frame textColor:(UIColor *)textColor {
    UILabel *subText = [[UILabel alloc] initWithFrame:frame];
    subText.textColor = textColor;
    subText.font = AVGetRegularFont(12);
    subText.numberOfLines = 0;
    subText.text = AUILiveRecordPushString(text);
    return subText;
}

@end
