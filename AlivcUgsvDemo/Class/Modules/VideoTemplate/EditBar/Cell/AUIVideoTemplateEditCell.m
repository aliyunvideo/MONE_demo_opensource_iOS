//
//  AUIVideoTemplateEditCell.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/12/22.
//

#import "AUIVideoTemplateEditCell.h"
#import "AUIFoundation.h"
#import "AUIUgsvMacro.h"
#import <SDWebImage/SDWebImage.h>

@interface AUIVideoTemplateEditCell ()

@property (nonatomic, strong) id<AUIVideoTemplateEditItemProtocol> item;

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIView *coverMaskView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) AVBaseButton *selectedBtn;

@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation AUIVideoTemplateEditCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectZero];
        coverView.backgroundColor = AUIFoundationColor(@"fill_medium");
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        coverView.layer.cornerRadius = 2.0;
        coverView.layer.masksToBounds = YES;
        [coverView av_setLayerBorderColor:AUIFoundationColor(@"colourful_border_strong")];
        [self.contentView addSubview:coverView];
        self.coverView = coverView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textColor = AUIFoundationColor(@"text_ultraweak");
        titleLabel.font = AVGetRegularFont(9.0);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIView *coverMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        coverMaskView.backgroundColor = AUIFoundationColor(@"tsp_fill_weak");
        [self.coverView addSubview:coverMaskView];
        self.coverMaskView = coverMaskView;
        
        UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        durationLabel.textColor = AUIFoundationColor(@"text_strong");
        durationLabel.font = AVGetMediumFont(10.0);
        durationLabel.textAlignment = NSTextAlignmentRight;
        [self.coverView addSubview:durationLabel];
        self.durationLabel = durationLabel;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textColor = AUIFoundationColor(@"text_strong");
        textLabel.font = AVGetRegularFont(10.0);
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.numberOfLines = 0;
        [self.coverView addSubview:textLabel];
        self.textLabel = textLabel;
        
        AVBaseButton *selectedBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        selectedBtn.backgroundColor = AUIFoundationColor(@"tsp_fill_ultraweak");
        selectedBtn.title = AUIUgsvGetString(@"点击编辑");
        selectedBtn.font = AVGetRegularFont(9.0);
        selectedBtn.image = AUIUgsvTemplateImage(@"ic_edit");
        selectedBtn.spacing = 2;
        selectedBtn.insets = UIEdgeInsetsMake(10, 6, 10, 6);
        selectedBtn.hidden = YES;
        [self.coverView addSubview:selectedBtn];
        self.selectedBtn = selectedBtn;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverView.frame = CGRectMake(0, 0, 52, 52);
    self.coverView.av_centerX = self.contentView.av_width / 2.0;
    
    self.coverMaskView.frame = self.coverView.bounds;
    self.durationLabel.frame = CGRectMake(0, 0, self.coverView.av_width - 4, 16);
    self.durationLabel.av_bottom = self.coverView.av_height - 4;
    
    self.textLabel.frame = self.coverView.bounds;
    
    self.selectedBtn.frame = self.coverView.bounds;
    
    self.titleLabel.frame = CGRectMake(0, 0, self.contentView.av_width, 14);
    self.titleLabel.av_top = self.coverView.av_bottom + 8;
}

- (void)updateItem:(id<AUIVideoTemplateEditItemProtocol>)item {
    self.item = item;
    __weak typeof(self) weakSelf = self;
    self.item.refreshCoverBlock = ^(id<AUIVideoTemplateEditItemProtocol> item){
        if (item != weakSelf.item) {
            return;
        }
        [weakSelf refreshCover];
    };
    self.item.refreshTextBlock = ^(id<AUIVideoTemplateEditItemProtocol> item){
        if (item != weakSelf.item) {
            return;
        }
        [weakSelf refreshText];
    };
    self.item.refreshSelectedBlock = ^(id<AUIVideoTemplateEditItemProtocol> item){
        if (item != weakSelf.item) {
            return;
        }
        [weakSelf refreshSelected];
    };
    
    [self refreshCover];
    [self refreshText];
    [self refreshSelected];
    self.durationLabel.text = [NSString stringWithFormat:@"%.1fs", self.item.duration];
    self.titleLabel.text = self.item.title;
    self.coverMaskView.hidden = !self.item.itemMedia;
}

- (void)refreshCover {
    if (self.item.itemMusic.selectedModel.music.coverUrl.length > 0) {
        [self.coverView sd_setImageWithURL:[NSURL URLWithString:self.item.itemMusic.selectedModel.music.coverUrl]];
    }
    else {
        [self.coverView sd_cancelCurrentImageLoad];
        self.coverView.image = self.item.coverImage;
    }
}

- (void)refreshText {
    self.textLabel.text = self.item.text;
}

- (void)refreshSelected {
    self.selectedBtn.hidden = self.item.itemMusic || !self.item.selected;
    self.durationLabel.hidden = !self.item.itemMedia || self.item.selected;
    self.coverView.layer.borderWidth = self.item.selected ? 1.0 : 0.0;
}

@end
