//
//  AlivcPlayerAsset.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/6/30.
//

#import "AlivcPlayerAsset.h"

@implementation AlivcPlayerAsset

/*
 APColorTypeTheme,
 
 APColorTypeBg,           // #FFFFFF 100%
 APColorTypeBg2,          // #FAFAFA 100%
 APColorTypeBg3,          // #F7F7F7 100%
 APColorTypeBgBorder,     // #979797 100%
 
 APColorTypeFg,           // #333333 100%
 APColorTypeFg2,          // #555555 100%
 APColorTypeFg3,          // #333333 80%
 
 // 播放器配色
 APColorTypeVideoBg,      // #000000 100%
 APColorTypeVideoFg,      // #FFFFFF 100%
 APColorTypeVideoFg2,     // #E6E6E6 100%
 */

+ (UIColor *)colorWithType:(APColorType)type {
    static NSDictionary *_globalColorMap = nil;
    if (!_globalColorMap) {
        _globalColorMap = @{
            @(APColorTypeTheme) : [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0],
            // 背景色
            @(APColorTypeBg) : [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],
            @(APColorTypeBg2) : [UIColor colorWithRed:0xfa/255.0 green:0xfa/255.0 blue:0xfa/255.0 alpha:1.0],
            @(APColorTypeBg3) : [UIColor colorWithRed:0xf7/255.0 green:0xf7/255.0 blue:0xf7/255.0 alpha:1.0],
            @(APColorTypeBgBorder) : [UIColor colorWithRed:0x97/255.0 green:0x97/255.0 blue:0x97/255.0 alpha:1.0],
            // 前景色
            @(APColorTypeFg) : [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0],
            @(APColorTypeFg2) : [UIColor colorWithRed:0x55/255.0 green:0x55/255.0 blue:0x55/255.0 alpha:1.0],
            @(APColorTypeFg3) : [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:0.8],
            // 播放器配色
            @(APColorTypeVideoBg) : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],
            @(APColorTypeVideoFg) : [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],
            @(APColorTypeVideoFg2) : [UIColor colorWithRed:0xe6/255.0 green:0xe6/255.0 blue:0xe6/255.0 alpha:1.0],
            @(APColorTypeVideoBg40) : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4],
            @(APColorTypeWhiteBg20) :  [UIColor colorWithRed:0xfa/255.0 green:0xfa/255.0 blue:0xfa/255.0 alpha:0.2],
            @(APColorTypeCyanBg20) : [UIColor colorWithRed:0x00/255.0 green:0xf2/255.0 blue:0xff/255.0 alpha:0.2],
            @(APColorTypeCyanBg) : [UIColor colorWithRed:0x00/255.0 green:0xf2/255.0 blue:0xff/255.0 alpha:1.0],
            @(APColorTypeWhiteBg70)  : [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.7],
            @(APColorTypeWhiteBg40)  : [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0.4],
            @(APColorTypeGrayD4) :[UIColor colorWithRed:0xd4/255.0 green:0xd4/255.0 blue:0xd4/255.0 alpha:1],
            @(APColorTypeLineE) :[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1],
            @(APColorTypeText18): [UIColor colorWithRed:0x18/255.0 green:0x18/255.0 blue:0x18/255.0 alpha:1],
            @(APColorTypeAirPlayEmpty): [UIColor colorWithRed:0x8b/255.0 green:0x8b/255.0 blue:0x8b/255.0 alpha:1],
            @(APColorTypeCCC): [UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:1],
            @(APColorTypeVideoBg60) : [UIColor colorWithRed:0x00/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:0.6],
            @(APColorTypeListenVideo) : [UIColor colorWithRed:0x42/255.0 green:0x46/255.0 blue:0x4B/255.0 alpha:1],

            
        };
    }
    
    return [_globalColorMap objectForKey:@(type)];
}

+ (UIImage *)imageWithKey:(NSString *)key {
    return [UIImage imageNamed:key];
}

@end
