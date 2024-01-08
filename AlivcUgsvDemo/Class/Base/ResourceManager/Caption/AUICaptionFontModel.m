//
//  AUICaptionFontModel.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/20.
//

#import "AUICaptionFontModel.h"
#import "AUIUgsvMacro.h"

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>


@implementation AUICaptionFontModel

- (instancetype)initWithResourcePath:(NSString *)resourcePath
{
    self = [super initWithResourcePath:resourcePath];
    if (self) {
        self.fontName = [self.class registerFontWithFontPath:self.resourcePath];
        NSString *temp = [resourcePath lastPathComponent];
        temp = [temp stringByDeletingPathExtension];
        self.showName = temp;
       
        if (temp) {
            self.pority = [k_sortDict()[temp] floatValue];
        }
    }
    return self;
}


+ (NSString *)registerFontWithFontPath:(NSString *)fontPath {
    NSString *fontPathFormat = [NSString stringWithFormat:@"%@",fontPath];
    NSData *dynamicFontData;
    dynamicFontData = [NSData dataWithContentsOfFile:fontPathFormat];
    if (!dynamicFontData) {
        fontPathFormat = [fontPathFormat stringByReplacingOccurrencesOfString:@".ttf" withString:@".TTF"];
        dynamicFontData = [NSData dataWithContentsOfFile:fontPathFormat];
        NSLog(@"font path rename befor:%@",fontPath);
        NSLog(@"font path renamed:%@",fontPathFormat);
    }
    if (!dynamicFontData) {
        NSLog(@"font data read error:%@", fontPath);
        return nil;
    }
    NSURL *fontUrl = [NSURL fileURLWithPath:fontPathFormat];
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)dynamicFontData);
    CGFontRef font = CGFontCreateWithDataProvider(providerRef);
    CFStringRef cfFontName = CGFontCopyPostScriptName(font);
    NSString *fontName = (__bridge NSString *)cfFontName;
//    @try {
//        CTFontManagerRegisterGraphicsFont(font, &error);
//    } @catch (NSException *exception) {
//
//    }
    
    if (CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontUrl,kCTFontManagerScopeProcess,&error)) {
        UIFont *keepFontRegister = [UIFont fontWithName:fontName size:10];
        if (!keepFontRegister) {
            NSLog(@"font register not success: can not get font call [UIFont fontWithName:size:]");
            CFRelease(font);
            CFRelease(cfFontName);
            CFRelease(providerRef);
            return nil;
        }
    }else{
        
        NSInteger errorCode = CFErrorGetCode(error);//105 表示已经注册过
            NSLog(@"errorcode == %zd",errorCode);
        if (errorCode == kCTFontManagerErrorAlreadyRegistered) {
            
        }else{
            CFRelease(font);
            CFRelease(cfFontName);
            CFRelease(providerRef);
            return nil;
        }
    }
    
    NSLog(@"font:%@ register success", fontName);
    CFRelease(font);
    CFRelease(cfFontName);
    CFRelease(providerRef);
    
    return fontName;
}

static  NSDictionary * k_sortDict(void)
{
    return   @{          
        AUIUgsvGetString(@"默认字体"):@"0",
        @"快乐体":@"1",
    };
}

+ (AUIResourceModel *)EmptyModel
{
    AUICaptionFontModel *model = [[AUICaptionFontModel alloc] init];
    model.showName = AUIUgsvGetString(@"默认字体");
    return model;
}

@end
