//
//  AUIPlayerStatusBar.m
//  RCStatusBar
//
//  Created by mengyehao on 2021/6/29.
//  Copyright © 2021 RongCheng. All rights reserved.
//

#import "AUIPlayerStatusBar.h"
#import "AlivcPlayerAsset.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "AlivcPlayerReachability.h"


const static CGFloat kContentHeight = 24;

@interface AUIPlayerStatusBar()
@property (nonatomic, strong) UILabel *netLabel;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *batteryLabel;
@property (nonatomic, strong) CAShapeLayer *batteryLayer;
@property (nonatomic, strong) CALayer *outlineLayer;
@property (nonatomic, strong) CALayer *outRightlineLayer;




@property (nonatomic, assign) BOOL is24H;
@end

@implementation AUIPlayerStatusBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    /// 时间
    UILabel *dateLabel = [[UILabel alloc]init];
    dateLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"dateLabel");
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.font = AVGetRegularFont(12);
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    UILabel *netLabel = [[UILabel alloc]init];
    netLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"netLabel");
    netLabel.textColor = [UIColor whiteColor];
    netLabel.font = AVGetRegularFont(12);
    [self addSubview:netLabel];
    self.netLabel = netLabel;
    
 
    CAShapeLayer *batteryLayer = [CAShapeLayer layer];
    batteryLayer.lineWidth = 1;
    batteryLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:batteryLayer];
    self.batteryLayer = batteryLayer;

    
    UILabel *batteryLabel = [[UILabel alloc]init];
    batteryLabel.accessibilityIdentifier = AUIVideoFlowAccessibilityStr(@"batteryLabel");
    batteryLabel.textColor = [UIColor whiteColor];
    batteryLabel.font = AVGetRegularFont(12);
    batteryLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:batteryLabel];
    self.batteryLabel = batteryLabel;
}


- (BOOL)is24H{
    if(!_is24H){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
        NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
        _is24H = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    }
    return _is24H;
}

- (void)updateData
{
    
    CGFloat kMargrnX = 50;
  
    CGFloat width = MAX(  [UIScreen mainScreen].bounds.size.width,   [UIScreen mainScreen].bounds.size.height);
    
    self.dateLabel.frame = CGRectMake(0, 0, 100, kContentHeight);
    self.dateLabel.center = CGPointMake(width*0.5,  self.dateLabel.center.y);
    
    self.netLabel.text = [self.class getNetType];
    self.netLabel.frame = CGRectMake(kMargrnX, 0, 100, kContentHeight);
    
    self.batteryLabel.frame = CGRectMake(width-24-24-2-kMargrnX, 0, kMargrnX, kContentHeight);
    
    [self.outRightlineLayer removeFromSuperlayer];
    
    [self.outlineLayer removeFromSuperlayer];
    
    
    //    /// 电池
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(width-24-24, (kContentHeight - 12)/2, 22, 12) cornerRadius:2.6];
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.lineWidth = 1;
        lineLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
        lineLayer.path = bezierPath.CGPath;
        lineLayer.fillColor = nil; // 默认为blackColor
        [self.layer addSublayer:lineLayer];
        self.outlineLayer = lineLayer;

        // 正极
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(width-24-2.5, (kContentHeight - 4)/2, 1.5, 4) byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomRight) cornerRadii:CGSizeMake(2, 2)];
        CAShapeLayer *lineLayer2 = [CAShapeLayer layer];
        lineLayer2.lineWidth = 1;
        lineLayer2.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
        lineLayer2.path = path.CGPath;
        lineLayer2.fillColor = lineLayer.strokeColor; // 默认为blackColor
        [self.layer addSublayer:lineLayer2];
        self.outRightlineLayer = lineLayer2;
    
    
    //时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *currentDateString = [formatter stringFromDate:[NSDate date]];
    self.dateLabel.text = currentDateString;
  
    
    //电池
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0) {
        batteryLevel = batteryLevel * -1;
    }
    
    
    UIColor *batteryColor;
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    if(batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull){ // 在充电 绿色
        batteryColor = [AUIPlayerStatusBar colorWithHexString:@"#37CB46"];

    }else{
        if(batteryLevel <= 0.2){ // 电量低
            if([NSProcessInfo processInfo].lowPowerModeEnabled){ // 开启低电量模式 黄色
                batteryColor = [AUIPlayerStatusBar colorWithHexString:@"#F9CF0E"];
            }else{ // 红色
                batteryColor = [AUIPlayerStatusBar colorWithHexString:@"#F02C2D"];
            }
        }else{ // 电量正常 白色
            batteryColor = [UIColor whiteColor];
        }
    }
    
    UIBezierPath *batteryPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(width-24-22.5, (kContentHeight - 9)/2, (22-3)*batteryLevel, 9) cornerRadius:2];
    self.batteryLayer.path = batteryPath.CGPath;
    self.batteryLayer.fillColor = batteryColor.CGColor;
    
    
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%",batteryLevel*100];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString{
    NSString*cString=[[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if([cString length]< 6)
        return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor whiteColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
    
}

+ (NSString *)getNetType{

    NSString *netconnType = @"";

    AlivcPlayerReachability *reach = [AlivcPlayerReachability reachabilityWithHostName:@"www.apple.com"];

    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {

            netconnType = @"no network";
        }
            break;

        case ReachableViaWiFi:// Wifi
        {
            netconnType = @"WiFi";
        }
            break;

        case ReachableViaWWAN:// 手机自带网络
        {
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            NSString *currentNet = @"";
            
            if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
                currentNet = @"GPRS";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
                currentNet = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]){
                currentNet = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]){
                currentNet = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]){
                currentNet = @"2G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]){
                currentNet = @"HRPD";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
                currentNet = @"4G";
            }else if (@available(iOS 14.1, *)) {
                if ([currentStatus isEqualToString:CTRadioAccessTechnologyNRNSA]){
                    currentNet = @"5G NSA";
                }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyNR]){
                    currentNet = @"5G";
                }
            }
            netconnType = currentNet;
        }
            break;

        default:
            break;
    }

    return netconnType;
}
@end
