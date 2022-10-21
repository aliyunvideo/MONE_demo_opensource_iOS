//
//  AVTheme.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define AVGetColor(key, module)  [AVTheme colorWithNamed:(key) withModule:(module)]
#define AVGetColor2(key, opacity, module)  [AVTheme colorWithNamed:(key) withOpacity:(opacity) withModule:(module)]
#define AVGetImage(key, module)  [AVTheme imageWithNamed:(key) withModule:(module)]

#define AVGetSemiboldFont(size)  [AVTheme semiboldFont:(size)]
#define AVGetMediumFont(size)  [AVTheme mediumFont:(size)]
#define AVGetRegularFont(size)  [AVTheme regularFont:(size)]
#define AVGetLightFont(size)  [AVTheme lightFont:(size)]
#define AVGetUltralightFont(size)  [AVTheme ultralightFont:(size)]


@interface AVTheme : NSObject

+ (UIColor *)colorWithNamed:(NSString *)name withModule:(NSString *)module;
+ (UIColor *)colorWithNamed:(NSString *)name withOpacity:(CGFloat)opacity withModule:(NSString *)module;
+ (UIImage *)imageWithNamed:(NSString *)name withModule:(NSString *)module;

+ (UIFont *)semiboldFont:(CGFloat)size;
+ (UIFont *)mediumFont:(CGFloat)size;
+ (UIFont *)regularFont:(CGFloat)size;
+ (UIFont *)lightFont:(CGFloat)size;
+ (UIFont *)ultralightFont:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
