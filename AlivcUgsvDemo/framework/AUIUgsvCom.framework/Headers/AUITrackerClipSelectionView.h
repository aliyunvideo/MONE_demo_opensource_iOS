//
//  AUITrackerClipSelectionView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <UIKit/UIKit.h>

@interface AUITrackerClipSelectionView : UIView

@property (nonatomic, strong, readonly) UIImageView *leftView;
@property (nonatomic, strong, readonly) UIImageView *rightView;

@property (nonatomic, assign) BOOL enablePanGesture;

@end
