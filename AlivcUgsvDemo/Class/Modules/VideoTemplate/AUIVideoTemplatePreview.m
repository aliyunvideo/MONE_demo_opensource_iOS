//
//  AUIVideoTemplatePreview.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/14.
//

#import "AUIVideoTemplatePreview.h"
#import "AUIAssetPlay.h"
#import "AUIUgsvMacro.h"
#import "AUIVideoTemplateEditor.h"

@interface AUIVideoTemplatePreview ()

@property (nonatomic, strong) AUIVideoTemplateItem *item;
@property (nonatomic, strong) AUIAssetPlay *player;
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation AUIVideoTemplatePreview

- (instancetype)initWithTemplateItem:(AUIVideoTemplateItem *)item {
    self = [super init];
    if (self) {
        _item = item;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.headerLineView.hidden = YES;
    self.hiddenMenuButton = YES;
    
    self.contentView.frame = self.view.bounds;
    [self.view bringSubviewToFront:self.headerView];
    
    UIView *displayView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:displayView];
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [playBtn setImage:nil forState:UIControlStateNormal];
    [playBtn setImage:AUIUgsvTemplateImage(@"ic_preview_play") forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(onPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:playBtn];
    self.playBtn = playBtn;
    
    CAGradientLayer *bottomLayer = [CAGradientLayer layer];
    bottomLayer.frame = CGRectMake(0, self.contentView.av_height - 180, self.contentView.av_width, 180);
    bottomLayer.colors = @[(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.0].CGColor,(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.7].CGColor];
    bottomLayer.startPoint = CGPointMake(0.5, 0);
    bottomLayer.endPoint = CGPointMake(0.5, 1);
    [self.contentView.layer addSublayer:bottomLayer];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.av_width - 72 - 20, self.contentView.av_height - 32 - AVSafeBottom - 5, 72, 32)];
    nextButton.backgroundColor = AUIFoundationColor(@"colourful_fg_strong");
    nextButton.titleLabel.font = AVGetRegularFont(14);
    [nextButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [nextButton setTitle:AUIUgsvGetString(@"下一步") forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 16.0;
    nextButton.layer.masksToBounds = YES;
    [nextButton addTarget:self action:@selector(onNextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:nextButton];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    infoLabel.text = self.item.info;
    infoLabel.textColor = AUIFoundationColor(@"text_weak");
    infoLabel.font = AVGetRegularFont(12);
    infoLabel.frame = CGRectMake(20, nextButton.av_centerY - 9, nextButton.av_left - 20 - 12, 18);
    [self.contentView addSubview:infoLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = self.item.name;
    titleLabel.textColor = AUIFoundationColor(@"text_strong");
    titleLabel.font = AVGetRegularFont(14);
    titleLabel.numberOfLines = 2;
    CGSize fitSize = [titleLabel sizeThatFits:CGSizeMake(self.contentView.av_width - 20 * 2, 0)];
    titleLabel.frame = CGRectMake(20, infoLabel.av_top - fitSize.height - 12, fitSize.width, fitSize.height);
    [self.contentView addSubview:titleLabel];
    
    UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    durationLabel.text = [AVStringFormat formatWithDuration:self.item.duration];
    durationLabel.textColor = AUIFoundationColor(@"text_strong");
    durationLabel.font = AVGetRegularFont(12);
    durationLabel.frame = CGRectMake(20, titleLabel.av_top - 18, self.contentView.av_width - 20 * 2, 18);
    [self.contentView addSubview:durationLabel];
    
    NSURL *sourceURL = nil;
    if ([self.item.url hasPrefix:@"http"]) {
        sourceURL = [NSURL URLWithString:self.item.url];
    }
    else {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Template.bundle" ofType:nil];
        NSString *local = [bundlePath stringByAppendingPathComponent:self.item.url];
        sourceURL = [NSURL fileURLWithPath:local];
    }
    AVAsset *asset = [AVAsset assetWithURL:sourceURL];
    self.player = [[AUIAssetPlay alloc] initWithAsset:asset];
    self.player.isLoopPlay = YES;
    [self.player setDisplayView:displayView];
    [self.player play];
}

- (void)onPlayBtnClicked:(UIButton *)sender {
    if (sender.selected) {
        [self.player play];
        sender.selected = NO;
    }
    else {
        [self.player pause];
        sender.selected = YES;
    }
}

- (void)onNextButtonClicked:(UIButton *)sender {
    [self.player pause];
    self.playBtn.selected = YES;

    AUIVideoTemplateOutputParam *param = [AUIVideoTemplateOutputParam new];
//    param.bpp = 0.75;
    param.saveToAlbumExportCompleted = YES;
    [AUIVideoTemplateEditor openEditor:self.item outputParam:param currentVC:self];
}

@end
