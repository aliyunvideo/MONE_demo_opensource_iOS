//
//  AUIVideoListManager.h
//  AliPlayerDemo
//
//  Created by zzy on 2022/3/23.
//  Copyright © 2022 com.alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUIVideoListModel.h"

@interface AUIVideoListManager : NSObject

+ (instancetype)manager;
+ (NSArray<AUIVideoListModel *> *)convertSourceData;
- (BOOL)isHideHandUp;
- (BOOL)isHideBottomMoreTip;
- (void)hideHandUp;
- (void)showBottomMoreTip;
- (void)hideBottomMoreTip;

@end
