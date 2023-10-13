//
//  AlivcLiveParamModel.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *AlivcLiveParamModelReuseCellInput = @"AlivcLiveParamModelReuseCellInput";
static NSString *AlivcLiveParamModelReuseCellSlider = @"AlivcLiveParamModelReuseCellSlider";
static NSString *AlivcLiveParamModelReuseCellSliderHeader= @"AlivcLiveParamModelReuseCellSliderHeader";

static NSString *AlivcLiveParamModelReuseCellSwitch = @"AlivcLiveParamModelReuseCellSwitch";
static NSString *AlivcLiveParamModelReuseCellSwitchButton = @"AlivcLiveParamModelReuseCellSwitchButton";
static NSString *AlivcLiveParamModelReuseCellSwitchSetButton = @"AlivcLiveParamModelReuseCellSwitchSetButton";

static NSString *AlivcLiveParamModelReuseCellPickerSelect = @"AlivcLiveParamModelReuseCellPickerSelect";
static NSString *AlivcLiveParamModelReuseCellSelectCustomOpen = @"AlivcLiveParamModelReuseCellSelectCustomOpen";
static NSString *AlivcLiveParamModelReuseCellSegment = @"AlivcLiveParamModelReuseCellSegment";
static NSString *AlivcLiveParamModelReuseCellSegmentAtRecord = @"AlivcLiveParamModelReuseCellSegmentAtRecord";
static NSString *AlivcLiveParamModelReuseCellTick = @"AlivcLiveParamModelReuseCellTick";

static NSString *AlivcLiveParamModelReuseCellSegmentWhite = @"AlivcLiveParamModelReuseCellSegmenWhite";


@interface AlivcLiveParamModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, copy) NSString *reuseId;
@property (nonatomic, assign) BOOL inputNotEnable;
@property (nonatomic, copy) NSString *infoText;
@property (nonatomic, copy) NSString *infoUnit;
@property (nonatomic, strong) UIColor *infoColor;
@property (nonatomic, copy) NSArray *pickerPanelTextArray;
@property (nonatomic, copy) NSArray *segmentTitleArray;
@property (nonatomic, assign) CGFloat defaultValue;

@property (nonatomic, copy) NSString *titleAppose; // 并排显示 switch title
@property (nonatomic, assign) CGFloat defaultValueAppose; // 并排显示 switch value

@property (nonatomic, copy) void(^valueBlock)(int value);
@property (nonatomic, copy) void(^switchBlock)(int index, BOOL open);
@property (nonatomic, copy) void(^sliderBlock)(int value);
@property (nonatomic, copy) void(^pickerSelectBlock)(int value);
@property (nonatomic, copy) void(^selectCustomOpenBlock)(void);
@property (nonatomic, copy) void(^segmentBlock)(int value);
@property (nonatomic, copy) void(^switchButtonBlock)(void);
@property (nonatomic, copy) void(^tickBlock)(void);
@property (nonatomic, copy) void(^stringBlock)(NSString *message);

@end
