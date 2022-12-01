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
#define AVGetCommonImage(key, module)  [AVTheme imageWithCommonNamed:(key) withModule:(module)]

#define AVGetSemiboldFont(size)  [AVTheme semiboldFont:(size)]
#define AVGetMediumFont(size)  [AVTheme mediumFont:(size)]
#define AVGetRegularFont(size)  [AVTheme regularFont:(size)]
#define AVGetLightFont(size)  [AVTheme lightFont:(size)]
#define AVGetUltralightFont(size)  [AVTheme ultralightFont:(size)]

typedef NS_ENUM(NSUInteger, AVThemeMode) {
    AVThemeModeAuto,  //supportsAutoMode为NO时，与Light一致
    AVThemeModeLight,
    AVThemeModeDark,
};

@interface AVTheme : NSObject

@property (nonatomic, assign, class) AVThemeMode currentMode;

// App是否支持自动模式
// YES时，支持AVThemeModeAuto，切换模式时实时生效
// NO时，AVThemeModeAuto与Light一致，切换模式时必须重启APP生效，
// iOS13及以上以上默认为YES，其他默认为NO。当你APP不支持多种主题模式时（即使是iOS13及以上），建议设置为NO，并选择Light或Dark作为你的界面UI样式
@property (nonatomic, assign, class) BOOL supportsAutoMode;

+ (UIColor *)colorWithNamed:(NSString *)named withModule:(NSString *)moduleNamed;
+ (UIColor *)colorWithNamed:(NSString *)named withOpacity:(CGFloat)opacity withModule:(NSString *)moduleNamed;

+ (UIImage *)imageWithNamed:(NSString *)named withModule:(NSString *)moduleNamed;
+ (UIImage *)imageWithCommonNamed:(NSString *)named withModule:(NSString *)moduleNamed;
+ (UIImage *)imageWithLightNamed:(NSString *)lightNamed withDarkNamed:(NSString *)darkNamed inBundle:(nullable  NSBundle *)bundle;

+ (UIFont *)semiboldFont:(CGFloat)size;
+ (UIFont *)mediumFont:(CGFloat)size;
+ (UIFont *)regularFont:(CGFloat)size;
+ (UIFont *)lightFont:(CGFloat)size;
+ (UIFont *)ultralightFont:(CGFloat)size;

+ (UIStatusBarStyle)preferredStatusBarStyle;

+ (void)updateRootViewInterfaceStyle:(UIView *)view;
+ (void)updateRootViewControllerInterfaceStyle:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
