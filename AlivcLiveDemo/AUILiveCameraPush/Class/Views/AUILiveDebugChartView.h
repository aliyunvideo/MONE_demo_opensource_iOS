//
//  AUILiveDebugChartView.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 2017/10/9.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcLivePushStatsInfo;

@interface AUILiveDebugChartView : UIView


- (void)updateData:(AlivcLivePushStatsInfo *)info;

@end
