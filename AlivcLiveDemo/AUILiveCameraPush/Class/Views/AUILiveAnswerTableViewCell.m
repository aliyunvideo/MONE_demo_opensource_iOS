//
//  AUILiveAnswerTableViewCell.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2018/1/22.
//  Copyright © 2018年 TripleL. All rights reserved.
//

#import "AUILiveAnswerTableViewCell.h"
#import "AlivcLiveQuestionModel.h"

@interface AUILiveAnswerTableViewCell ()

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UIButton *sendQuestoinButton;
@property (nonatomic, strong) UIButton *sendAnswerButton;
@property (nonatomic, strong) UIView *lineView;


@end

@implementation AUILiveAnswerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.numberLabel  = [[UILabel alloc] init];
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    self.numberLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.numberLabel];
    
    self.questionLabel  = [[UILabel alloc] init];
    self.questionLabel.textColor = [UIColor whiteColor];
    self.questionLabel.numberOfLines = 0;
    self.questionLabel.font = [UIFont systemFontOfSize:12.f];
    [self.contentView addSubview:self.questionLabel];
    
    self.sendQuestoinButton = [self setupButtonWithFrame:CGRectZero normalTitle:AUILiveCameraPushString(@"下发题目") selectTitle:nil action:@selector(questionButtonAction:)];

    [self.contentView addSubview:self.sendQuestoinButton];
    self.sendAnswerButton = [self setupButtonWithFrame:CGRectZero normalTitle:AUILiveCameraPushString(@"下发答案") selectTitle:nil action:@selector(answerButtonAction:)];
    [self.contentView addSubview:self.sendAnswerButton];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.lineView];
}



- (void)layoutSubviews {
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    CGFloat labelWidth = 50;

    self.numberLabel.frame = CGRectMake(0, 0, labelWidth, cellHeight);
    self.questionLabel.frame = CGRectMake(labelWidth, 0, cellWidth - labelWidth * 3, cellHeight);
    self.sendQuestoinButton.frame = CGRectMake(cellWidth - labelWidth*2, 0, labelWidth, cellHeight);
    self.sendAnswerButton.frame = CGRectMake(cellWidth - labelWidth, 0, labelWidth, cellHeight);
    self.lineView.frame = CGRectMake(0, cellHeight - 1, cellWidth, 1);

}


- (UIButton *)setupButtonWithFrame:(CGRect)rect normalTitle:(NSString *)normal selectTitle:(NSString *)select action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setTitle:normal forState:(UIControlStateNormal)];
    [button setTitle:select forState:(UIControlStateSelected)];
    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [button setTitleColor:[UIColor grayColor] forState:(UIControlStateDisabled)];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = rect.size.height / 5;
    return button;
}


- (void)setupQuestionModel:(AlivcLiveQuestionModel *)model {
    
    self.numberLabel.text = model.questionId;
    self.questionLabel.text = model.content;
}


- (void)questionButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate onClickAnswerTableViewQuestionButton:self];
    }
}


- (void)answerButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate onClickAnswerTableViewAnswerButton:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
