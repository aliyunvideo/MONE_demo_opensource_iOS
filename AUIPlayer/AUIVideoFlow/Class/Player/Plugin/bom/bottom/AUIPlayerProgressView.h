//
//  AUIPlayerProgressView.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/23.
//

#import <UIKit/UIKit.h>



@interface AUIPlayerProgressView : UIView
@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIColor *trackTintColor;
@property (nonatomic, strong) UIColor *progressTintColor;

@end


