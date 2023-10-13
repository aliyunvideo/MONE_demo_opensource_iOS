//
//  AUIShortEpisodeEntranceView.m
//  AlivcPlayerDemo
//
//  Created by Bingo on 2023/9/16.
//

#import "AUIShortEpisodeEntranceView.h"
#import "AUIShortEpisodeMacro.h"
#import "AUIFoundation.h"

@interface AUIShortEpisodeEntranceView ()

@property (nonatomic, strong) UIImageView *playIcon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *statIcon;


@end

@implementation AUIShortEpisodeEntranceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = AVTheme.fill_medium;
        self.layer.masksToBounds = YES;
        
        _playIcon = [UIImageView new];
        _playIcon.image = SECommonImage(@"ic_decoration");
        [self addSubview:_playIcon];
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = AVTheme.text_ultrastrong;
        _titleLabel.font = AVGetRegularFont(12);
        _titleLabel.text = @"";
        [self addSubview:_titleLabel];
        
        _statIcon = [UIImageView new];
        _statIcon.backgroundColor = AVTheme.fill_strong;
        _statIcon.contentMode = UIViewContentModeScaleAspectFit;
        _statIcon.layer.cornerRadius = 11;
        _statIcon.layer.masksToBounds = YES;
        _statIcon.image = SECommonImage(@"ic_expand");
        [self addSubview:_statIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.av_height / 2.0;
    self.playIcon.frame = CGRectMake(16, (self.av_height - 20) / 2.0, 20, 20);
    self.statIcon.frame = CGRectMake(self.av_width - 36 - 16, (self.av_height - 20) / 2.0, 36, 20);
    self.titleLabel.frame = CGRectMake(self.playIcon.av_right + 4, (self.av_height - 18) / 2.0, self.statIcon.av_left - self.playIcon.av_right - 4 - 4, 18);
}

@end
