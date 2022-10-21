//
//  AUILiveParamTableViewCell.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcLiveParamModel;

@interface AUILiveParamTableViewCell : UITableViewCell

@property (nonatomic, strong) AlivcLiveParamModel *cellModel;

- (void)configureCellModel:(AlivcLiveParamModel *)cellModel;

- (void)updateDefaultValue:(int)value enable:(BOOL)enable;
- (void)updateEnable:(BOOL)enable;
- (void)closeInputStatus;

@end
