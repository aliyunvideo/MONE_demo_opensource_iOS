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

- (UIView *)getSubAtIndex:(NSUInteger)index;

@end
@implementation AUILivePushReplayKitTipProgress

#define kProgressBaseTag 10

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2.0 - 1, 0, 2, frame.size.height)];
        line.backgroundColor = AUILiveCommonColor(@"ir_sheet_button");
        line.tag = kProgressBaseTag + 0;
        [self addSubview:line];
        
        UIButton *oneBtn = [self getProgressButtonWithName:@"1" frame:CGRectMake(0, 0, 24, 24)];
        oneBtn.tag = kProgressBaseTag + 1;
        [self addSubview:oneBtn];
        
        UIButton *twoBtn = [self getProgressButtonWithName:@"2" frame:CGRectMake(0, oneBtn.av_bottom, 24, 24)];
        twoBtn.tag = kProgressBaseTag + 2;
        [self addSubview:twoBtn];
        
        UIButton *threeBtn = [self getProgressButtonWithName:@"3" frame:CGRectMake(0, twoBtn.av_bottom, 24, 24)];
        threeBtn.tag = kProgressBaseTag + 3;
        [self addSubview:threeBtn];
    }
    return self;
}

- (UIView *)getSubAtIndex:(NSUInteger)index {
    return [self viewWithTag:kProgressBaseTag + index];
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
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(42, 180, self.view.av_width - 42 * 2, self.view.av_height - 180 * 2)];
    tipView.backgroundColor = AUIFoundationColor(@"bg_weak");
    [self.view addSubview:tipView];
    
    UILabel *tipHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, tipView.av_width, 23)];
    tipHeaderLabel.text = AUILiveRecordPushString(@"录屏使用说明");
    tipHeaderLabel.textAlignment = NSTextAlignmentCenter;
    tipHeaderLabel.textColor = AUIFoundationColor(@"text_strong");
    tipHeaderLabel.font = AVGetRegularFont(17);
    [tipView addSubview:tipHeaderLabel];
    
    UIView *progressTipView = [[UIView alloc] initWithFrame:CGRectMake(24, tipHeaderLabel.av_bottom + 24, tipView.av_width - 24 * 2, 170)];
    [tipView addSubview:progressTipView];
    
    AUILivePushReplayKitTipProgress *tipProgress = [[AUILivePushReplayKitTipProgress alloc] initWithFrame:CGRectMake(24, 0, 24, progressTipView.av_height)];
    [progressTipView addSubview:tipProgress];
    
    UILabel *oneProgressText = [self getProgressText:AUILiveRecordPushString(@"请先到控制中心，长按启动系统屏幕录制") frame:CGRectMake(tipProgress.av_right + 16, 0, progressTipView.av_width - tipProgress.av_right - 16, 40)];
    CGSize oneProgressTextSize = [oneProgressText sizeThatFits:CGSizeMake(oneProgressText.av_width, MAXFLOAT)];
    if (oneProgressTextSize.height > oneProgressText.av_height) {
        oneProgressText.av_height = oneProgressTextSize.height;
    }
    [progressTipView addSubview:oneProgressText];
    
    UILabel *oneProgressSubText = [self getSubText:AUILiveRecordPushString(@"若无此选项请从设置中的控制中心里添加") frame:CGRectMake(tipProgress.av_right + 16, oneProgressText.av_bottom + 3, progressTipView.av_width - tipProgress.av_right - 16, 24) textColor:AUIFoundationColor(@"text_weak")];
    CGSize oneProgressSubTextSize = [oneProgressSubText sizeThatFits:CGSizeMake(oneProgressSubText.av_width, MAXFLOAT)];
    if (oneProgressSubTextSize.height > oneProgressSubText.av_height) {
        oneProgressSubText.av_height = oneProgressSubTextSize.height;
    }
    [progressTipView addSubview:oneProgressSubText];
    
    UILabel *twoProgressText = [self getProgressText:AUILiveRecordPushString(@"选择AlivcLiveBroadcast") frame:CGRectMake(tipProgress.av_right + 16, oneProgressSubText.av_bottom + 8, progressTipView.av_width - tipProgress.av_right - 16, 24)];
    CGSize twoProgressTextSize = [twoProgressText sizeThatFits:CGSizeMake(twoProgressText.av_width, MAXFLOAT)];
    if (twoProgressTextSize.height > twoProgressText.av_height) {
        twoProgressText.av_height = twoProgressTextSize.height;
    }
    [progressTipView addSubview:twoProgressText];
    
    [tipProgress getSubAtIndex:2].av_top = twoProgressText.av_top;
    
    CGFloat threePregressTextTop = twoProgressText.av_bottom + ([tipProgress getSubAtIndex:2].av_top - [tipProgress getSubAtIndex:1].av_bottom);
    UILabel *threeProgressText = [self getProgressText:AUILiveRecordPushString(@"请先到控制中心，长按启动系统屏幕录制") frame:CGRectMake(tipProgress.av_right + 16, threePregressTextTop, progressTipView.av_width - tipProgress.av_right - 16, 40)];
    CGSize threeProgressTextSize = [threeProgressText sizeThatFits:CGSizeMake(threeProgressText.av_width, MAXFLOAT)];
    if (threeProgressTextSize.height > threeProgressText.av_height) {
        threeProgressText.av_height = threeProgressTextSize.height;
    }
    [progressTipView addSubview:threeProgressText];
    
    [tipProgress getSubAtIndex:0].av_height = threeProgressText.av_top;
    [tipProgress getSubAtIndex:3].av_top = threeProgressText.av_top;
    
    if (threeProgressText.av_bottom > progressTipView.av_height) {
        progressTipView.av_height = threeProgressText.av_bottom;
        tipProgress.av_height = progressTipView.av_height;
    }
    
    UIView *warningTipView = [[UIView alloc] initWithFrame:CGRectMake(24, progressTipView.av_bottom + 18, tipView.av_width - 24 * 2, 120)];
    [tipView addSubview:warningTipView];
    
    UILabel *warningTopLabel = [self getSubText:AUILiveRecordPushString(@"注意：以上设置仅载开始推流前有效，推流后改变设置无效") frame:CGRectMake(18, 0, warningTipView.av_width - 18 * 2, 35) textColor: AUIFoundationColor(@"text_strong")];
    CGSize warningTopLabelSize = [warningTopLabel sizeThatFits:CGSizeMake(warningTopLabel.av_width, MAXFLOAT)];
    if (warningTopLabelSize.height > warningTopLabel.av_height) {
        warningTopLabel.av_height = warningTopLabelSize.height;
    }
    [warningTipView addSubview:warningTopLabel];
    
    UILabel *warningBottomLabel = [self getSubText:AUILiveRecordPushString(@"iOS13系统由于剪切板限制，无法向extension传递配置信息。请修改SampleHandler.m源码中的配置信息，实现录屏演示。") frame:CGRectMake(18, warningTopLabel.av_bottom + 8, warningTipView.av_width - 18 * 2, 68) textColor: AUIFoundationColor(@"text_weak")];
    CGSize warningBottomLabelSize = [warningBottomLabel sizeThatFits:CGSizeMake(warningBottomLabel.av_width, MAXFLOAT)];
    if (warningBottomLabelSize.height > warningBottomLabel.av_height) {
        warningBottomLabel.av_height = warningBottomLabelSize.height;
    }
    [warningTipView addSubview:warningBottomLabel];
    
    if (warningBottomLabel.av_bottom > warningTipView.av_height) {
        warningTipView.av_height = warningBottomLabel.av_bottom;
    }
    
    CGFloat tipContentHeight = warningTipView.av_bottom + 16 + 21;
    if (tipContentHeight > tipView.av_height) {
        tipView.av_height = tipContentHeight;
        tipView.av_top = (self.view.av_height - tipContentHeight) / 2.0;
    }
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, tipView.av_height - 21 - 16 / 2.0, tipView.av_width, 21);
    [closeBtn setTitle:AUILiveCommonString(@"确定") forState:UIControlStateNormal];
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
    progressText.text = text;
    return progressText;
}

- (UILabel *)getSubText:(NSString *)text frame:(CGRect)frame textColor:(UIColor *)textColor {
    UILabel *subText = [[UILabel alloc] initWithFrame:frame];
    subText.textColor = textColor;
    subText.font = AVGetRegularFont(12);
    subText.numberOfLines = 0;
    subText.text = text;
    return subText;
}

@end
