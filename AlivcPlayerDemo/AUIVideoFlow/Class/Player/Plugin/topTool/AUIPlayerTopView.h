//
//  AUIPlayerTopView.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/16.
//

#import <UIKit/UIKit.h>
#import "AUIPlayerStatusBar.h"
#import "AUIPlayerTopActionView.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerTopView : UIView
@property (nonatomic) BOOL landScape;
@property (nonatomic) BOOL listening;

@property (nonatomic) AUIPlayerStatusBar *statusBar;
@property (nonatomic) AUIPlayerTopActionView *topActionView;

@end

NS_ASSUME_NONNULL_END
