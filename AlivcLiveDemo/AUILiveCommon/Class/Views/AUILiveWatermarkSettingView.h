//
//  AUILiveWatermarkSettingView.h
//  AlivcLivePusherTest
//
//  Created by TripleL on 2017/10/12.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    float watermarkX;
    float watermarkY;
    float watermarkWidth;
} AlivcWatermarkSettingStruct;

@interface AUILiveWatermarkSettingDrawView : UIView

- (AlivcWatermarkSettingStruct)getWatermarkSettingsWithCount:(NSInteger)index;


- (BOOL)isEditing;

@end


@interface AUILiveWatermarkSettingView : UIView

@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, strong) UITextField *xTextField;
@property (nonatomic, strong) UITextField *yTextField;
@property (nonatomic, strong) UITextField *wTextField;


- (instancetype)initWithFrame:(CGRect)frame
                 defaultValue:(NSArray<NSString *> *)defaultValues;

- (AlivcWatermarkSettingStruct)getWatermarkSetting;

@end
