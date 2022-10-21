//
//  AUIPhotoAlbumCell.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/27.
//

#import "AUIPhotoAlbumCell.h"
#import "AUIPhotoLibraryManager.h"

@interface AUIPhotoAlbumCell ()

@property (nonatomic, strong, readonly) AUIPhotoAlbumModel *albumModel;

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *infoLabel;
@property (nonatomic, strong, readonly) UIImageView *thumbView;
@property (nonatomic, strong, readonly) UIView *lineView;


@end

@implementation AUIPhotoAlbumCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thumbView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbView.backgroundColor = AUIFoundationColor(@"fg_strong");
        _thumbView.layer.cornerRadius = 4;
        _thumbView.layer.masksToBounds = YES;
        [self.contentView addSubview:_thumbView];

        _titleLabel = [UILabel new];
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _titleLabel.font = AVGetMediumFont(14);
        _titleLabel.numberOfLines = 1;
        _titleLabel.text = @"";
        [self.contentView addSubview:_titleLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = AUIFoundationColor(@"text_ultraweak");
        _infoLabel.font = AVGetMediumFont(12);
        _infoLabel.numberOfLines = 1;
        _infoLabel.text = @"";
        [self.contentView addSubview:_infoLabel];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = AUIFoundationColor(@"border_infrared");
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.thumbView.frame = CGRectMake(20, (self.contentView.av_height - 72) / 2.0, 72, 72);
    self.titleLabel.frame = CGRectMake(self.thumbView.av_right + 12, (self.contentView.av_height - (22+18+4)) / 2.0, self.contentView.av_width - self.thumbView.av_right - 20 - 12, 22);
    self.infoLabel.frame = CGRectMake(self.titleLabel.av_left, self.titleLabel.av_bottom + 4, self.titleLabel.av_width, 18);
    self.lineView.frame = CGRectMake(self.titleLabel.av_left, self.contentView.av_height - 1, self.contentView.av_width - self.titleLabel.av_left, 1);
}

- (void)updateAlbumModel:(AUIPhotoAlbumModel *)albumModel {
    _albumModel = albumModel;
    self.titleLabel.text = albumModel.albumName;
    self.infoLabel.text = [NSString stringWithFormat:@"%zd", albumModel.assetsCount];
    [AUIPhotoLibraryManager getPostImageWithAlbumModel:albumModel sortAscendingByModificationDate:NO completion:^(UIImage * _Nonnull postImage) {
        self.thumbView.image = postImage;
    }];
}

@end
