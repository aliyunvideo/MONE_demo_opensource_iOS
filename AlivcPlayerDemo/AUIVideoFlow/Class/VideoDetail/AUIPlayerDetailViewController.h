//
//  AUIPlayerDetailViewController.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/1.
//

#import "AVBaseViewController+AUIPlayerFlowSpecial.h"
@class AlivcPlayerVideo;

NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerDetailViewController : AVBaseViewController
@property (nonatomic, strong) AlivcPlayerVideo *item;
@property (nonatomic, copy) NSArray<AlivcPlayerVideo *> *recommendList;

@end

NS_ASSUME_NONNULL_END
