//
//  AlivcPlayerAsset.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/6/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
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
    APColorTypeVideoBg40,    // #000000 40%
    APColorTypeVideoBg60,    // #000000 60%

    APColorTypeWhiteBg20,    // #FFFFFF 20%
    APColorTypeWhiteBg70,    // #FFFFFF 20%
    APColorTypeWhiteBg40,    // #FFFFFF 20%


    APColorTypeCyanBg20,     //#00F2FF 20%
    APColorTypeCyanBg,       //#00F2FF 100%
    
    APColorTypeGrayD4,       //#d4d4d4 100%
    
    APColorTypeLineE,        //EEEEEEE
    
    APColorTypeText18,       //#181818 100%
    APColorTypeAirPlayEmpty,       //#8B8B8B 100%
    APColorTypeCCC,          //#CCCCCC
    APColorTypeListenVideo,                          //#42464B

    
    
} APColorType;

#define APGetColor(type) [AlivcPlayerAsset colorWithType:type]

@interface AlivcPlayerAsset : NSObject

+ (UIColor *)colorWithType:(APColorType)type;


@end

NS_ASSUME_NONNULL_END
