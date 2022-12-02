//
//  AUIMusicCell.m
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/8.
//

#import "AUIMusicCell.h"
#import "Masonry.h"
#import "AUIUgsvMacro.h"
#import "AVBaseButton.h"
#import "AUIMusicStateModel.h"
#import "AVCircularProgressView.h"
#import "AUIMusicCropView.h"
#import "YYWebImage.h"

@interface AUIMusicCell () <AUIMusicStateModelDelegate>
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *playIcon;
@property (nonatomic, strong) UIImageView *downloadIcon;
@property (nonatomic, strong) AVBaseButton *useBtn;
@property (nonatomic, strong) AVCircularProgressView *progressView;
@property (nonatomic, strong) AUIMusicCropView *cropView;
@end

@implementation AUIMusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) prepareForReuse {
    [super prepareForReuse];
    [_coverImageView yy_cancelCurrentImageRequest];
}

- (void) setup {
    // clear
    [_mainView removeFromSuperview];
    [_coverImageView removeFromSuperview];
    [_titleLabel removeFromSuperview];
    [_artistNameLabel removeFromSuperview];
    [_durationLabel removeFromSuperview];
    [_playIcon removeFromSuperview];
    [_downloadIcon removeFromSuperview];
    [_useBtn removeFromSuperview];
    [_progressView removeFromSuperview];
    
    // create
    self.backgroundColor = UIColor.clearColor;
    self.backgroundView = [UIView new];
    self.backgroundView.backgroundColor = UIColor.clearColor;
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = UIColor.clearColor;
    
    _mainView = [UIView new];
    _mainView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:_mainView];
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(70.0);
    }];
    
    _coverImageView = [UIImageView new];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.layer.cornerRadius = 4.0;
    _coverImageView.layer.masksToBounds = YES;
    [_mainView addSubview:_coverImageView];
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50.0);
        make.left.equalTo(_mainView).inset(20.0);
        make.top.bottom.equalTo(_mainView).inset(10.0);
    }];
    
    const CGFloat kUseBtnHeight = 24.0;
    _useBtn = [AVBaseButton TextButton];
    _useBtn.backgroundColor = AUIFoundationColor(@"colourful_fill_strong");
    _useBtn.layer.cornerRadius = kUseBtnHeight * 0.5;
    _useBtn.layer.masksToBounds = YES;
    _useBtn.font = AVGetMediumFont(12.0);
    _useBtn.color = AUIFoundationColor(@"text_strong");
    _useBtn.title = AUIUgsvGetString(@"使用");
    _useBtn.userInteractionEnabled = NO;
    [_mainView addSubview:_useBtn];
    [_useBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kUseBtnHeight);
        make.width.mas_equalTo(52.0);
        make.centerY.equalTo(_mainView);
        make.right.equalTo(_mainView).inset(30.0);
    }];

    _titleLabel = [UILabel new];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = AVGetRegularFont(12.0);
    _titleLabel.textColor = AUIFoundationColor(@"text_strong");
    [_mainView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_coverImageView.mas_right).inset(12.0);
        make.top.equalTo(_coverImageView.mas_top);
        make.right.equalTo(_useBtn.mas_left).inset(4.0);
    }];
    
    _artistNameLabel = [UILabel new];
    _artistNameLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
    _artistNameLabel.textAlignment = NSTextAlignmentLeft;
    _artistNameLabel.font = AVGetRegularFont(10.0);
    _artistNameLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    [_mainView addSubview:_artistNameLabel];
    [_artistNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom);
    }];
    
    _durationLabel = [UILabel new];
    _durationLabel.font = AVGetRegularFont(8.0);
    _durationLabel.textColor = AUIFoundationColor(@"text_ultraweak");
    [_mainView addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_artistNameLabel);
        make.top.equalTo(_artistNameLabel.mas_bottom).inset(4.0);
    }];
    
    _playIcon = [UIImageView new];
    _playIcon.image = AUIUgsvGetImage(@"ic_music_note");
    [_mainView addSubview:_playIcon];
    [_playIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_mainView).inset(30.0);
        make.centerY.equalTo(_mainView);
    }];
    
    _downloadIcon = [UIImageView new];
    _downloadIcon.image = AUIUgsvGetImage(@"ic_music_download");
    [_mainView addSubview:_downloadIcon];
    [_downloadIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_mainView).inset(30.0);
        make.centerY.equalTo(_mainView);
    }];
    
    _progressView = [AVCircularProgressView new];
    [_mainView addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16.0);
        make.center.equalTo(_downloadIcon);
    }];
    
    // update
    [self updateUI];
}

- (void) updateStateUI {
    _downloadIcon.hidden = (_model.state != AUIMusicResourceStateNetwork);
    _playIcon.hidden = (_model.state != AUIMusicResourceStateLocal || !self.selected);
    _useBtn.hidden = (_model.state != AUIMusicResourceStateLocal || self.selected);
    _progressView.hidden = (_model.state != AUIMusicResourceStateDownloading);
    [_progressView setProgress:_model.downloadProgress animated:YES];
}

- (void) updateUI {
    if (!_model) {
        return;
    }
    
    AUIMusicModel *music = _model.music;
    [_coverImageView yy_setImageWithURL:[NSURL URLWithString:music.coverUrl]
                            placeholder:AUIUgsvGetImage(@"ic_music_cover_placeholder")
                                options:YYWebImageOptionSetImageWithFadeAnimation|YYWebImageOptionIgnoreImageDecoding // 服务端提供的图片过大，直接解码会爆内存
                               progress:nil
                              transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        return [image yy_imageByResizeToSize:CGSizeMake(150, 150) contentMode:UIViewContentModeScaleAspectFill];
    } completion:nil];
    _titleLabel.text = music.title;
    _artistNameLabel.text = music.artistName;
    _durationLabel.text = music.formatDuration;
    
    [self updateStateUI];
}

- (void) setModel:(AUIMusicStateModel *)model {
    if (_model == model) {
        return;
    }
    if (_model.delegate == self) {
        _model.delegate = nil;
    }
    self.isShowCropView = NO;
    
    _model = model;
    _model.delegate = self;
    [self updateUI];
}

- (BOOL) canSelected {
    return (_model && _model.state == AUIMusicResourceStateLocal);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (!self.canSelected) {
        return;
    }
    [self updateUI];
}

- (void)setPlayer:(id<AUIVideoPlayProtocol>)player {
    _player = player;
    _cropView.player = player;
}

- (void) setIsShowCropView:(BOOL)isShowCropView {
    if (_isShowCropView == isShowCropView) {
        return;
    }
    _isShowCropView = isShowCropView;
    
    if (isShowCropView) {
        _cropView = [[AUIMusicCropView alloc] initWithLimitDuration:_limitDuration
                                                      selectedModel:_selectedModel
                                                             player:self.player];
        [self.contentView addSubview:_cropView];
        [_cropView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(70.0);
        }];
        
        __weak typeof(self) weakSelf = self;
        _cropView.onCropConfirm = ^(AUIMusicSelectedModel *model) {
            if ([weakSelf.delegate respondsToSelector:@selector(onAUIMusicCell:didCropMusic:)]) {
                [weakSelf.delegate onAUIMusicCell:weakSelf didCropMusic:model];
            }
        };
    }
    else {
        [_cropView removeFromSuperview];
        _cropView = nil;
    }
}

// MARK: - AUIMusicStateModelDelegate
- (void) onAUIMusicStateModel:(AUIMusicStateModel *)model didChangeState:(AUIMusicResourceState)state {
    [self updateStateUI];
    if ([_delegate respondsToSelector:@selector(onAUIMusicCell:stateDidChange:)]) {
        [_delegate onAUIMusicCell:self stateDidChange:state];
    }
}

- (void) onAUIMusicStateModel:(AUIMusicStateModel *)model didChangeProgress:(float)progress {
    [_progressView setProgress:_model.downloadProgress animated:YES];
}

@end
