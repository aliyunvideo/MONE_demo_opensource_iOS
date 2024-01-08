//
//  AUIPlayerVideoDetailViewCell.m
//  ApsaraVideo
//
//  Created by mengyehao on 2021/8/16.
//

#import "AUIPlayerVideoDetailViewCell.h"
#import <Masonry/Masonry.h>
#import "AlivcPlayerAsset.h"
#import "AlivcPlayerVideo.h"
#import <SDWebImage/SDWebImage.h>
#import "AlivcPlayerManager.h"


@interface AlivcPlayerVideoDetailViewUserInfoCell()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation AlivcPlayerVideoDetailViewUserInfoCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.userNameLabel];

        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descLabel];
        
        self.avatarView.layer.cornerRadius = 10;
        self.avatarView.clipsToBounds = YES;
        
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(16);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self.contentView).offset(16);
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.height.mas_equalTo(20);

        }];
        
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView).offset(16);
            make.height.mas_equalTo(20);
            make.top.equalTo(self.avatarView.mas_bottom).offset(8);

        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.right.equalTo(self.contentView.mas_right).offset(-16);

            make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-16);
        }];
        
        UIView *bomLinew = [UIView new];
        bomLinew.backgroundColor = AUIFoundationColor(@"border_weak");
        [self.contentView addSubview:bomLinew];
        
        [bomLinew mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
    
        
    }
    return self;
}

- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [UIImageView new];
        _avatarView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_userInfoCell_avatarView");
        _avatarView.image = AUIVideoFlowImage(@"comment_avatar");
        _avatarView.clipsToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarView;
}

- (UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        _userNameLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_userInfoCell_userNameLabel");
        _userNameLabel.font = AVGetRegularFont(12);
        _userNameLabel.textColor = AUIFoundationColor(@"text_medium");
        _userNameLabel.numberOfLines = 1;
    }
    return _userNameLabel;
}


- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
        _titleLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_userInfoCell_titleLabel");
        _titleLabel.font = AVGetMediumFont(14);
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
        _descLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_userInfoCell_descLabel");
        _descLabel.font = AVGetRegularFont(12);
        _descLabel.numberOfLines= 0;
        _descLabel.textColor = AUIFoundationColor(@"text_medium");
    }
    return _descLabel;
}

- (void)setItem:(AlivcPlayerVideo *)item
{
    _item = item;
    NSURL *url = [NSURL URLWithString:item.coverUrl?:@""];
    [self.avatarView sd_setImageWithURL:url placeholderImage:AUIVideoFlowImage(@"comment_avatar")];
    self.userNameLabel.text = item.user.userName;

    self.titleLabel.text = item.title;
    
    self.descLabel.text = [self.class videoAbout];
}

+ (NSString *)videoAbout {
    return AUIVideoFlowString(@"故事发生在星球大战：最后的绝地武士死星陨落的五年后，围绕在远离新共和国掌控的银河系边远星带的的一位独行枪手展开。");;
}

+ (CGFloat)getCellHeight {
    UILabel *label = [[UILabel alloc] init];
    label.font = AVGetRegularFont(12);
    label.numberOfLines= 0;
    label.text = [self videoAbout];
    CGSize size = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 16 * 2, MAXFLOAT)];
    return size.height + 72.0 + 16.0;
}


+ (NSString *)timeformatFromMilSeconds:(NSInteger)seconds {
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
@end



@interface AlivcPlayerVideoSeletedArtInnerCell : UICollectionViewCell

@property (nonatomic, assign) bool isPlaying;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation AlivcPlayerVideoSeletedArtInnerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        
        [self.contentView addSubview:self.containerView];
        [self.containerView addSubview:self.titleLabel];
        
        self.containerView.clipsToBounds = YES;
        self.containerView.layer.cornerRadius = 4;
        self.containerView.backgroundColor = APGetColor(APColorTypeVideoFg2);
        self.containerView.layer.borderWidth = 1;
        self.containerView.layer.borderColor =   UIColor.clearColor.CGColor;
   

        
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.containerView).offset(4);
            make.right.bottom.equalTo(self.containerView).offset(-4);

            
            
        }];
        
    
        
   

    }
    return self;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_artInnerCell_containerView");
    }
    return _containerView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
        _titleLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_artInnerCell_titleLabel");
        _titleLabel.font = AVGetMediumFont(14);
        _titleLabel.textColor = APGetColor(APColorTypeFg);
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (void)setIsPlaying:(bool)isPlaying
{
    
    self.containerView.backgroundColor = isPlaying ?APGetColor(APColorTypeCyanBg20): APGetColor(APColorTypeVideoFg2);
    self.containerView.layer.borderColor = isPlaying ?APGetColor(APColorTypeCyanBg20).CGColor: UIColor.clearColor.CGColor;
}


@end



@interface AlivcPlayerVideoDetailViewSeletedArtCell()<UICollectionViewDelegate, UICollectionViewDataSource>
//@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation AlivcPlayerVideoDetailViewSeletedArtCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        
        [self.contentView addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
        
        UIView *bomLinew = [UIView new];
        bomLinew.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_artCell_bomLinew");
        bomLinew.backgroundColor = APGetColor(APColorTypeLineE);
        [self.contentView addSubview:bomLinew];
        
        [bomLinew mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(86.f, 50.f);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        flowLayout.minimumLineSpacing = 8;


        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.av_width, 50.f) collectionViewLayout:flowLayout];
        _collectionView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_artCell_collectionView");
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:AlivcPlayerVideoSeletedArtInnerCell.class forCellWithReuseIdentifier:@"AlivcPlayerVideoSeletedArtInnerCell"];
        
        if (@available(iOS 14.0, *)) {
            UIBackgroundConfiguration *config = [UIBackgroundConfiguration clearConfiguration];
            UICollectionViewCell.appearance.backgroundConfiguration = config;
        }
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlivcPlayerVideoSeletedArtInnerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlivcPlayerVideoSeletedArtInnerCell" forIndexPath:indexPath];
    cell.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_artInnerCell");
    
    AlivcPlayerVideo *model = [self.dataList objectAtIndex:indexPath.row];
    
    NSString *string = [NSString stringWithFormat:@"第%ld话\n",indexPath.row+1];
    
    NSAttributedString *rich = [[NSAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName:AVGetRegularFont(10),
        NSForegroundColorAttributeName:APGetColor(APColorTypeFg2),

    }];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]init];
    [mutableAttributedString appendAttributedString:rich];
    rich = [[NSAttributedString alloc] initWithString:model.title?:@"" attributes:@{
        NSFontAttributeName:AVGetRegularFont(12),
        NSForegroundColorAttributeName:APGetColor(APColorTypeFg),

    }];
    [mutableAttributedString appendAttributedString:rich];

    
    cell.titleLabel.attributedText = mutableAttributedString;
    
    if ([AlivcPlayerManager manager].currentVideoId && [model.videoId isEqualToString:[AlivcPlayerManager manager].currentVideoId]) {
        cell.isPlaying = YES;
    } else {
        cell.isPlaying = NO;
    }
    return cell;
}

- (void)setDataList:(NSArray *)dataList
{
    _dataList = dataList;
    [self.collectionView reloadData];
}

 - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if (self.dataList.count > indexPath.row) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (self.onSeletedBlock) {
            self.onSeletedBlock(indexPath.row);
        }
        [collectionView reloadData];
    }
   
}

@end


@interface AlivcPlayerVideoDetailViewRecommendCell()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation AlivcPlayerVideoDetailViewRecommendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.timeLabel];
        
        self.avatarView.layer.cornerRadius = 4;
        self.avatarView.clipsToBounds = YES;
        
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.top.equalTo(self.contentView).offset(0);
            make.size.mas_equalTo(CGSizeMake(140, 82));
        }];
        

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.right.equalTo(self.contentView.mas_right).offset(-16);
            make.top.equalTo(self.contentView).offset(8);
            make.height.mas_equalTo(40);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.right.equalTo(self.contentView.mas_right).offset(-16);
            make.height.mas_equalTo(14);
            make.bottom.equalTo(self.avatarView.mas_bottom).offset(-8);
        }];
    
        UIView *emptyView = [UIView new];
        [self.contentView addSubview:emptyView];
        
        
        [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.contentView).offset(6);
            make.height.mas_equalTo(8);
        }];

        
    }
    return self;
}

- (void)setItem:(AlivcPlayerVideo *)item
{
    _item = item;
    NSURL *url = [NSURL URLWithString:item.coverUrl?:@""];
    [self.avatarView sd_setImageWithURL:url placeholderImage:AUIVideoFlowImage(@"comment_avatar")];
    
    self.titleLabel.text = item.title;
    
    _timeLabel.text = [self.class timeformatFromMilSeconds:item.duration * 1000];

}

- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [UIImageView new];
        _avatarView.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_recommendCell_avatarView");
        _avatarView.image = AUIVideoFlowImage(@"comment_avatar");
        _avatarView.clipsToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarView;
}


- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
        _titleLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_recommendCell_titleLabel");
        _titleLabel.font = AVGetRegularFont(14);
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 22)];
        _timeLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"playerDetailPage_recommendCell_timeLabel");
        _timeLabel.font = AVGetRegularFont(10);
        _timeLabel.textColor = AUIFoundationColor(@"text_medium");
    }
    return _timeLabel;
}

+ (NSString *)timeformatFromMilSeconds:(NSInteger)seconds {
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

@end


