//
//  AUILiveAnswerTableViewCell.h
//  AlivcLivePusherTest
//
//  Created by lyz on 2018/1/22.
//  Copyright © 2018年 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcLiveQuestionModel;

@protocol AUILiveAnswerTableViewCellDelegate;


@interface AUILiveAnswerTableViewCell : UITableViewCell

@property (nonatomic, weak) id<AUILiveAnswerTableViewCellDelegate> delegate;
- (void)setupQuestionModel:(AlivcLiveQuestionModel *)model;

@end


@protocol AUILiveAnswerTableViewCellDelegate <NSObject>

- (void)onClickAnswerTableViewQuestionButton:(AUILiveAnswerTableViewCell *)cell;
- (void)onClickAnswerTableViewAnswerButton:(AUILiveAnswerTableViewCell *)cell;

@end
