//
//  AUIMediaPublisher.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/7.
//

#import "AUIMediaPublisher.h"
#import "AUIMediaPublisherProgress.h"

#import <AUIUgsvCom/AUIUgsvCom.h>
#import "AUIPhotoPicker.h"
#import "AUIUgsvMacro.h"
#import "AUIUgsvPath.h"

@interface AUIMediaPublisher() <UITextViewDelegate>

@property (nonatomic, strong) id<AUIMediaProgressProtocol> exportProgress;
@property (nonatomic, strong) AUIMediaPublisherRequestInfo *requestInfo;
@property (nonatomic, strong) UIImage *coverImage;


@property (nonatomic, strong) UIButton *publishButton;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *pickLabel;

@property (nonatomic, strong) UIView *middleContentView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, assign) NSInteger maxLength;

@property (nonatomic, strong) AUIAsyncImageGeneratorVideo *imageGenerator;

@end

@implementation AUIMediaPublisher

- (instancetype)initWithExportProgress:(id<AUIMediaProgressProtocol>)exportProgress {
    self = [super init];
    if (self) {
        _exportProgress = exportProgress;
        _requestInfo = [AUIMediaPublisherRequestInfo new];
        _coverImage = nil;
    }
    return self;
}

- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath withThumbnailImage:(UIImage *)thumb {
    self = [super init];
    if (self) {
        _requestInfo = [AUIMediaPublisherRequestInfo new];
        _requestInfo.videoFilePath = videoFilePath;
        _coverImage = thumb;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.titleView.text = AUIUgsvGetString(@"发布");
    self.menuButton.hidden = YES;

    self.maxLength = 20;
    [self setupUI];
    
    __weak typeof(self) weakSelf = self;
    if (self.exportProgress) {
        if (self.exportProgress.requestCoverImageBlock) {
            self.exportProgress.requestCoverImageBlock(^(UIImage * _Nonnull coverImage) {
                weakSelf.coverImage = coverImage;
                weakSelf.coverImageView.image = weakSelf.coverImage;
            });
        }
    }
    else if (self.coverImage) {
        weakSelf.coverImageView.image = self.coverImage;
    }
    else if (self.requestInfo.videoFilePath.length > 0) {
        self.imageGenerator = [[AUIAsyncImageGeneratorVideo alloc] initWithPath:self.requestInfo.videoFilePath];
        [self.imageGenerator generateImagesAsynchronouslyForTimes:@[@(0)] duration:0 completed:^(NSTimeInterval time, UIImage *coverImage) {
            weakSelf.coverImage = coverImage;
            weakSelf.coverImageView.image = weakSelf.coverImage;
            weakSelf.imageGenerator = nil;
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundClick:)];
    [self.contentView addGestureRecognizer:tap];
}

- (void)setupUI
{
    [self.contentView addSubview:self.publishButton];
    [self.contentView addSubview:self.coverImageView];
    [self.coverImageView addSubview:self.pickLabel];
    [self.contentView addSubview:self.middleContentView];
    [self.middleContentView addSubview:self.textView];
    [self.middleContentView addSubview:self.tipsLabel];
}

- (UIButton *)publishButton
{
    if (!_publishButton) {
        _publishButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 229)/2, self.contentView.bounds.size.height - 54- 40, 229, 40)];
        _publishButton.layer.cornerRadius = _publishButton.av_height/2;
        _publishButton.backgroundColor = AUIFoundationColor(@"colourful_fg_strong");
        _publishButton.titleLabel.font = AVGetMediumFont(16);
        [_publishButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [_publishButton setTitle:AUIUgsvGetString(@"发布") forState:UIControlStateNormal];
        [_publishButton addTarget:self action:@selector(onPublishClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _publishButton;
}

- (UIImageView *)coverImageView
{
    if (!_coverImageView) {
        CGSize oriSize = CGSizeMake(self.contentView.av_width - 40, 145);
        CGSize resolution = CGSizeMake(oriSize.height * 9 / 16.0, oriSize.height);
        if ([self.exportProgress respondsToSelector:@selector(coverImageSize)]) {
            resolution = [self.exportProgress coverImageSize];
        }
        else if (self.coverImage) {
            resolution = CGSizeMake(self.coverImage.size.width * self.coverImage.scale, self.coverImage.size.height * self.coverImage.scale);
        }
        CGSize aspectSize = [UIView av_aspectSizeWithOriginalSize:oriSize withResolution:resolution];
        
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, aspectSize.width, aspectSize.height)];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.backgroundColor = AUIFoundationColor2(@"fill_infrared", 0.3);
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.layer.cornerRadius = 2.6;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCoverPickClick:)];
        [_coverImageView addGestureRecognizer:tap];
    }
    return _coverImageView;
}

- (UILabel *)pickLabel
{
    if (!_pickLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.coverImageView.av_height - 27, self.coverImageView.av_width, 27)];
        label.text = AUIUgsvGetString(@"选封面");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = AUIFoundationColor(@"text_strong");
        label.font = AVGetRegularFont(14);
        label.backgroundColor = AUIFoundationColor2(@"bg_weak", 0.8);
        _pickLabel = label;
    }

    return _pickLabel;
}

- (UIView *)middleContentView
{
    if (!_middleContentView) {
        _middleContentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.coverImageView.av_bottom + 20, self.contentView.av_width, 142)];
        _middleContentView.backgroundColor = AUIFoundationColor(@"bg_weak");
        [_middleContentView av_setLayerBorderColor:AUIFoundationColor(@"border_infrared") borderWidth:1.0];
    }
    return _middleContentView;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, self.middleContentView.av_width - 10 * 2, self.middleContentView.av_height - 20 * 2 - 20)];
        _textView.delegate = self;
        _textView.textColor = AUIFoundationColor(@"text_weak");
        _textView.font = AVGetMediumFont(14.0f);
        
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = AUIUgsvGetString(@"填写并使用合适的话题，让更多人看到");
        placeHolderLabel.numberOfLines = 1;
        placeHolderLabel.textColor = AUIFoundationColor(@"text_weak");
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        placeHolderLabel.font = AVGetMediumFont(14.0f);

        [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
        _textView.textContainerInset = UIEdgeInsetsMake(0, 4, 0, 0);
        _textView.backgroundColor = UIColor.clearColor;
    }
    return _textView;
}

- (UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, _textView.av_bottom, self.middleContentView.av_width - 20 *2, 20)];
        label.text = [NSString stringWithFormat:@"%d/%ld", 0,self.maxLength];
        label.textColor = AUIFoundationColor(@"text_weak");
        label.font = AVGetMediumFont(14);
        _tipsLabel = label;
    }

    return _tipsLabel;
}

- (void)onPublishClick:(id)sender
{
    self.requestInfo.desc = self.textView.text;
    if (!self.requestInfo.coverImagePath && self.coverImageView.image) {
        // generate cover image file
        NSString *coverImgPath = [[AUIUgsvPath cacheDir] stringByAppendingString:@"upload.png"];
        NSData *data = UIImagePNGRepresentation(self.coverImage);
        [data writeToFile:coverImgPath atomically:YES];
        self.requestInfo.coverImagePath  = coverImgPath;
    }
    
    AUIMediaPublisherProgress *publisherProgress = nil;
    if (self.exportProgress) {
        publisherProgress = [[AUIMediaPublisherProgress alloc] initWithExportProgress:self.exportProgress withPublishRequestInfo:self.requestInfo];
    }
    else {
        publisherProgress = [[AUIMediaPublisherProgress alloc] initWithRequestInfo:self.requestInfo];
    }
    AUIMediaProgressViewController *pvc = [[AUIMediaProgressViewController alloc] initWithHandle:publisherProgress];
    pvc.onFinish = ^(UIViewController * _Nonnull current, NSError * _Nullable error, id  _Nullable product) {
        if (self.onFinish) {
            self.onFinish(self, error, product);
        }
    };
    if (self.navigationController) {
        [self.navigationController pushViewController:pvc animated:YES];
    }
    else {
        [self av_presentFullScreenViewController:pvc animated:YES completion:nil];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
 
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && pos) {
        return;
    }
    
    NSRange selection = textView.selectedRange;
    NSInteger realLength = textView.text.length;
    NSString *headText = [textView.text substringToIndex:selection.location]; //光标前的文本
    NSString *tailText = [textView.text substringFromIndex:selection.location];//光标后的文本
    NSInteger restLength = self.maxLength - tailText.length; //光标后允许输入的文本长度
    if (realLength > self.maxLength) {
        NSString *subHeadText = [headText substringToIndex:restLength];
        textView.text = [subHeadText stringByAppendingString:tailText];
        [textView setSelectedRange:NSMakeRange(restLength, 0)];
    }
    
    self.tipsLabel.text = [NSString stringWithFormat:@"%ld/%ld",textView.text.length,self.maxLength];
}

- (void)onCoverPickClick:(id)sender
{
    AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:1 withAllowPickingImage:YES withAllowPickingVideo:NO withTimeRange:kCMTimeRangeZero];
    [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
        
        if (results.count > 0) {
            NSLog(@"%@", results.firstObject.filePath);
            self.coverImage = [UIImage imageWithContentsOfFile:results.firstObject.filePath];
            self.coverImageView.image = self.coverImage;
            self.requestInfo.coverImagePath = results.firstObject.filePath;
        }
        [sender dismissViewControllerAnimated:YES completion:nil];
        
    } withOutputDir:[AUIUgsvPath cacheDir]];
    [self av_presentFullScreenViewController:picker animated:YES completion:nil];
}

- (void)onBackgroundClick:(id)sender {
    [self.textView resignFirstResponder];
}

@end
