//
//  AVTheme.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/14.
//

#import "AVTheme.h"
#import "UIColor+AVHelper.h"
#import "NSDictionary+AVHelper.h"

@interface AVColorReader : NSObject

@property (nonatomic, copy) NSDictionary *lightColorMap;
@property (nonatomic, copy) NSDictionary *darkColorMap;


@end

@implementation AVColorReader

- (instancetype)initWithModule:(NSString *)module {
    self = [super init];
    if (self) {
        
        NSString *bundlePath = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:[module stringByAppendingString:@".bundle"]];
        
        NSString *darkPath = [bundlePath stringByAppendingString:@"/Theme/DarkMode/color.plist"];
        _darkColorMap = [NSDictionary dictionaryWithContentsOfFile:darkPath];
        
        NSString *lightPath = [bundlePath stringByAppendingString:@"/Theme/LightMode/color.plist"];
        _lightColorMap = [NSDictionary dictionaryWithContentsOfFile:lightPath];
        
    }
    return self;
}

- (UIColor *)colorNamed:(NSString *)name lightMode:(BOOL)lightMode {
    return lightMode ? [UIColor av_colorWithHexString:[self.lightColorMap av_stringValueForKey:name]] : [UIColor av_colorWithHexString:[self.darkColorMap av_stringValueForKey:name]];
}

@end


typedef NS_ENUM(NSUInteger, AVThemeMode) {
    AVThemeModeAuto,
    AVThemeModeLight,
    AVThemeModeDark,
};

@interface AVTheme ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, AVColorReader *> *moduleColorMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSBundle *> *moduleImageBundleMap;

@property (nonatomic, assign) AVThemeMode defaultMode;

@end

@implementation AVTheme

- (instancetype)init {
    self = [super init];
    if (self) {
        if (@available(iOS 13.0, *)) {
            // 暂时只支持Dark mode
//            self.defaultMode = AVThemeModeAuto;
            self.defaultMode = AVThemeModeDark;
        }
        else {
            self.defaultMode = AVThemeModeDark;
        }
    }
    return self;
}

- (AVColorReader *)addColorModule:(NSString *)module {
    if (module.length == 0) {
        return nil;
    }
    AVColorReader *colorReader = [self.moduleColorMap objectForKey:module];
    if (colorReader) {
        return colorReader;
    }
    colorReader = [[AVColorReader alloc] initWithModule:module];
    [self.moduleColorMap setObject:colorReader forKey:module];
    return colorReader;
}

- (UIColor *)colorNamed:(NSString *)name module:(NSString *)module {
    return [self colorNamed:name opacity:-1.0 module:module];
}

- (UIColor *)colorNamed:(NSString *)name opacity:(CGFloat)opacity module:(NSString *)module {
    if (name.length == 0) {
        return nil;
    }
    AVColorReader *colorReader = [self addColorModule:module];
    UIColor *lightColor = [colorReader colorNamed:name lightMode:YES];
    UIColor *darkColor = [colorReader colorNamed:name lightMode:NO];
    if (opacity >= 0) {
        lightColor = [lightColor colorWithAlphaComponent:opacity];
        darkColor = [darkColor colorWithAlphaComponent:opacity];
    }
    
    if (self.defaultMode == AVThemeModeDark) {
        NSAssert(darkColor, @"In dark mode, darkColor can't be nil");
        return darkColor;
    }
    else if (self.defaultMode == AVThemeModeLight) {
        NSAssert(lightColor, @"In light mode, lightColor can't be nil");
        return lightColor;
    }
    
    NSAssert(lightColor && darkColor, [NSString stringWithFormat:@"The color of the name does not exist. If supports light mode，lightColor can't be nil; If supports dark mode，darkColor can't be nil."]);
    return [UIColor av_colorWithLightColor:lightColor darkColor:darkColor];
}

- (NSBundle *)addImageModule:(NSString *)module {
    NSBundle *bundle = [self.moduleImageBundleMap objectForKey:module];
    if (bundle) {
        return bundle;
    }
    
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:[module stringByAppendingString:@".bundle/Theme"]];
    bundle = [NSBundle bundleWithPath:path];
    [self.moduleImageBundleMap setObject:bundle forKey:module];
    return bundle;
}

- (UIImage *)imageNamed:(NSString *)name module:(NSString *)module {
    if (name.length == 0) {
        return nil;
    }
    NSBundle *bundle = [self addImageModule:module];
    if (self.defaultMode == AVThemeModeDark) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"DarkMode/%@", name] inBundle:bundle compatibleWithTraitCollection:nil];
        return image;
    }
    else if (self.defaultMode == AVThemeModeLight) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"LightMode/%@", name] inBundle:bundle compatibleWithTraitCollection:nil];
        return image;
    }
    
    if (@available(iOS 13.0, *)) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"DarkMode/%@", name] inBundle:bundle compatibleWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]];
        [image.imageAsset registerImage:[UIImage imageNamed:[NSString stringWithFormat:@"LightMode/%@", name] inBundle:bundle compatibleWithTraitCollection:nil] withTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]];
        image = [image.imageAsset imageWithTraitCollection:UITraitCollection.currentTraitCollection];
        return image;
    } else {
        
    }
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.defaultMode == AVThemeModeDark) {
        return UIStatusBarStyleLightContent;
    }
    if (self.defaultMode == AVThemeModeLight) {
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent;
        } else {
            return UIStatusBarStyleDefault;
        }
    }
    return UIStatusBarStyleDefault;
}

+ (instancetype)currentTheme {
    static AVTheme *_global = nil;
    if (!_global) {
        _global = [AVTheme new];
    }
    
    return _global;
}

+ (UIColor *)colorWithNamed:(NSString *)name withModule:(NSString *)module {
    return [[self currentTheme] colorNamed:name module:module];
}

+ (UIColor *)colorWithNamed:(NSString *)name withOpacity:(CGFloat)opacity withModule:(NSString *)module {
    return [[self currentTheme] colorNamed:name opacity:opacity module:module];
}

+ (UIImage *)imageWithNamed:(NSString *)name withModule:(NSString *)module {
    return [[self currentTheme] imageNamed:name module:module];
}

+ (UIFont *)semiboldFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
}

+ (UIFont *)mediumFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Medium" size:size];
}

+ (UIFont *)regularFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
}

+ (UIFont *)lightFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Light" size:size];
}

+ (UIFont *)ultralightFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Ultralight" size:size];
}

+ (UIStatusBarStyle)preferredStatusBarStyle {
    return [[self currentTheme] preferredStatusBarStyle];
}

@end
