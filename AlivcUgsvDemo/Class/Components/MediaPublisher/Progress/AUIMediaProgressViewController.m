//
//  AUIMediaProgressViewController.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/10.
//

#import "AUIMediaProgressViewController.h"
#import "AUIMediaProgressView.h"
#import "AUIUgsvMacro.h"

@interface AUIMediaProgressViewController ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) AUIMediaProgressView *progressView;

@property (nonatomic, strong) id<AUIMediaProgressProtocol> handle;

@end

@implementation AUIMediaProgressViewController

- (instancetype)initWithHandle:(id<AUIMediaProgressProtocol>)handle {
    self = [super init];
    if (self) {
        self.handle = handle;
        _state = AUIMediaProgressStateInit;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.menuButton.hidden = YES;
    [self setupUI];
    
    __weak typeof(self) weakSelf = self;
    if ([self.handle respondsToSelector:@selector(setOnMediaFinishProgress:)]) {
        [self.handle setOnMediaFinishProgress:^(NSError * _Nonnull error, id _Nonnull product) {
                    if (error) {
                        [weakSelf onFinishFailed:error];
                    }
                    else {
                        [weakSelf onFinishSucceed:product];
                    }
        }];
    }
    if ([self.handle respondsToSelector:@selector(setOnMediaDoProgress:)]) {
        [self.handle setOnMediaDoProgress:^(float progress) {
            weakSelf.progressView.progress = progress;
        }];
    }
    
    if (self.handle.requestCoverImageBlock) {
        self.handle.requestCoverImageBlock(^(UIImage * _Nonnull coverImage) {
            weakSelf.coverImageView.image = coverImage;
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;  //禁用侧滑手势

    if (self.state == AUIMediaProgressStateInit) {
        if ([self.handle respondsToSelector:@selector(mediaStartProgress)]) {
            [self.handle mediaStartProgress];
            _state = AUIMediaProgressStateStarted;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;  //启用侧滑手势
}

- (void)setupUI
{
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.progressView];
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, self.contentView.av_width - 20 * 2, 35)];
        label.text = AUIUgsvGetString(@"努力导出中…");
        label.textColor = AUIFoundationColor(@"text_strong");
        label.font = AVGetMediumFont(22);
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;

        _textLabel = label;
    }
    
    return _textLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.textLabel
                                                                   .av_left, self.textLabel.av_bottom + 10, self.textLabel.av_width, 40)];
        label.text = AUIUgsvGetString(@"请努力保持屏幕点亮，不要锁屏或切换程序");
        label.textColor = AUIFoundationColor(@"text_strong");
        label.font = AVGetMediumFont(12);
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        _descLabel = label;
    }
    return _descLabel;
}

- (UIImageView *)coverImageView
{
    if (!_coverImageView) {
        
        CGSize oriSize = CGSizeMake(270, 270);
        CGSize resolution = CGSizeMake(oriSize.height * 9 / 16.0, oriSize.height);
        if ([self.handle respondsToSelector:@selector(coverImageSize)]) {
            resolution = [self.handle coverImageSize];
        }
        CGSize aspectSize = [UIView av_aspectSizeWithOriginalSize:oriSize withResolution:resolution];
        
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.contentView.av_width - aspectSize.width) / 2, self.descLabel.av_bottom + 30, aspectSize.width, aspectSize.height)];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.backgroundColor = AUIFoundationColor2(@"fill_infrared", 0.3);
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (AUIMediaProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[AUIMediaProgressView alloc] initWithFrame:self.coverImageView.frame];
    }
    return _progressView;
}


- (void)checkGoBack {
    if (self.state == AUIMediaProgressStateStarted) {
        [AVAlertController showWithTitle:AUIUgsvGetString(@"正在导出") message:AUIUgsvGetString(@"是否要退出") needCancel:YES onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                
                if ([self.handle respondsToSelector:@selector(mediaCancelProgress)]) {
                    [self.handle mediaCancelProgress];
                }
                [self goBack];
            }
        }];
    }
    else {
        [super goBack];
    }
}

- (void)onBackBtnClicked:(UIButton *)sender {
    [self checkGoBack];
}

- (void)onFinishSucceed:(id)product
{
    _state = AUIMediaProgressStateFinishSucceed;
    
    self.progressView.progress = 1;
    // TODO: 更新UI？
    
    
    if (self.onFinish) {
        self.onFinish(self, nil, product);
    }
}

- (void)onFinishFailed:(NSError *)error
{
    _state = AUIMediaProgressStateFinishFailed;

    // TODO: 更新UI？
    
    
    if (self.onFinish) {
        self.onFinish(self, error, nil);
    }
}


@end
