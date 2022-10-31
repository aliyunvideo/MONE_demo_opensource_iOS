//
//  AUIPlayerThumbnailView.m
//  AUIVideoFlow
//
//  Created by ISS013602000846 on 2022/6/7.
//

#import "AUIPlayerThumbnailView.h"
#import <SDWebImage/SDWebImage.h>
#import "AUIPlayerFlowAutoProgress.h"
#import "AlivcPlayerManager.h"

@interface AUIPlayerThumbnailView ()

@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UILabel *progressTimeLabel;
@property (nonatomic, strong) AUIPlayerFlowAutoProgress *progressView;

@end

@implementation AUIPlayerThumbnailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.thumbnailView];
        [self addSubview:self.progressTimeLabel];
        [self addSubview:self.progressView];
    }
    return self;
}

- (UIImageView *)thumbnailView
{
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] init];
        _thumbnailView.accessibilityIdentifier = [self accessibilityId:@"thumbnailView"];
        _thumbnailView.backgroundColor = AUIVideoFlowColor(@"vf_time_duration");
    }
    return _thumbnailView;
}

- (UILabel *)progressTimeLabel
{
    if (!_progressTimeLabel) {
        _progressTimeLabel = [[UILabel alloc] init];
        _progressTimeLabel.accessibilityIdentifier = [self accessibilityId:@"progressTimeLabel"];
        _progressTimeLabel.textAlignment = NSTextAlignmentCenter;
        _progressTimeLabel.font = AVGetRegularFont(28);
    }
    return _progressTimeLabel;
}

- (AUIPlayerFlowAutoProgress *)progressView {
    if (!_progressView) {
        _progressView = [[AUIPlayerFlowAutoProgress alloc] init];
        _progressView.accessibilityIdentifier = [self accessibilityId:@"progressView"];
    }
    return _progressView;
}

- (void)setStyle:(AUIPlayerThumbnailStyle)style {
    _style = style;
    [self uploadSubviews];
}

- (void)uploadSubviews {
    if (self.style == AUIPlayerThumbnailStylePortrait) {
        [self updateSelf];
        
        self.thumbnailView.hidden = YES;
        self.progressView.hidden = NO;
        self.progressTimeLabel.frame = CGRectMake(0, 0, self.av_width, 40);
        self.progressTimeLabel.font = AVGetRegularFont(28);
        self.progressView.frame = CGRectMake(0, self.av_height - 5, self.av_width, 5);
    } else {
        [self updateSelf];
        if (self.style == AUIPlayerThumbnailStyleLandscapeHasThumbnail) {
            self.thumbnailView.hidden = NO;
            self.progressView.hidden = YES;
            self.thumbnailView.frame = CGRectMake(0, 0, self.av_width, 116);
            self.progressTimeLabel.frame = CGRectMake(0, self.thumbnailView.av_bottom + 10, self.av_width, 40);
            self.progressTimeLabel.font = AVGetRegularFont(28);
        } else {
            self.thumbnailView.hidden = YES;
            self.progressView.hidden = YES;
            self.progressTimeLabel.frame = CGRectMake(0, 0, self.av_width, self.av_height);
            self.progressTimeLabel.font = AVGetRegularFont(14);
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([AlivcPlayerManager manager].currentOrientation == AlivcPlayerEventCenterTypeOrientationPortrait) {
        self.style = AUIPlayerThumbnailStylePortrait;
    }
    [self uploadSubviews];
}

- (void)updateSelf {
    if (self.style == AUIPlayerThumbnailStylePortrait) {
        self.av_width = 208;
        self.av_height = 55;
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 0;
    } else {
        if (self.style == AUIPlayerThumbnailStyleLandscapeHasThumbnail) {
            self.av_width = 208;
            self.av_height = 166;
            self.backgroundColor = [UIColor clearColor];
            self.layer.masksToBounds = NO;
            self.layer.cornerRadius = 0;
        } else {
            self.av_width = 150;
            self.av_height = 46;
            self.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
            self.layer.masksToBounds = YES;
            self.layer.cornerRadius = 8;
        }
    }
}

- (void)updateThumbnail:(nullable UIImage *)thumbnail positionTimeValue:(int64_t)position duration:(int64_t)duration {
    NSString *positionTime = [self timeformatFromMilSeconds:position];
    NSString *durationTime = [self timeformatFromMilSeconds:duration];
    durationTime = [@"/" stringByAppendingString:durationTime];
    NSString *progressTimeStr = [NSString stringWithFormat:@"%@%@", positionTime, durationTime];
    NSMutableAttributedString *progressTimeAttriStr = [[NSMutableAttributedString alloc] initWithString:progressTimeStr];
    [progressTimeAttriStr addAttribute:NSForegroundColorAttributeName value:AUIVideoFlowColor(@"vf_time_progress") range:[progressTimeStr rangeOfString:positionTime]];
    [progressTimeAttriStr addAttribute:NSForegroundColorAttributeName value:AUIVideoFlowColor(@"vf_time_duration")  range:[progressTimeStr rangeOfString:durationTime]];
    self.progressTimeLabel.attributedText = progressTimeAttriStr;
    
    if (self.style == AUIPlayerThumbnailStylePortrait) {
        self.progressView.progress = (float)position / (float)duration;
    } else if (self.style == AUIPlayerThumbnailStyleLandscapeHasThumbnail) {
        [self.thumbnailView setImage:thumbnail];
    }
}

- (NSString *)timeformatFromMilSeconds:(NSInteger)seconds {
    //s
    seconds = seconds/1000;
    
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long) (seconds / 60) % 60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long) seconds % 60];
    //format of time
    NSString *format_time = nil;

    format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
    
    return format_time;
}

- (NSString *)accessibilityId:(NSString *)key {
    NSString *name = NSStringFromClass([self class]);
    return [AUIVideoFlowAccessibilityStr(name) stringByAppendingString:key];
}

@end
