//
//  AUIPlayerLandScapeResolutionView.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import <UIKit/UIKit.h>


@interface AUIPlayerLandScapeResolutionView : UIView

@property (nonatomic,copy) NSArray<AVPTrackInfo *> *dataList;

@property (nonatomic, copy) void(^onTrackChanged)(AVPTrackInfo *);

- (void)updateCurrentSeleted:(AVPTrackInfo *)info;


@end

