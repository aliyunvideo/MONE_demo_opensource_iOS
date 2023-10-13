//
//  AUILiveSegmentPanel.h
//  OpensslTest
//
//  Created by ISS013602000846 on 2022/11/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveSegmentPanel : UIView

- (instancetype)initWithView:(UIView *)view items:(NSArray<NSString *> *)items animation:(BOOL)animation;

/// 设置Item下的内容
/// 格式为@[@[@{@"title": @"xxxx", @"image":@"xxxx"}], ...]
/// contents的数量必须和item的数量保持一致，且顺序保持一致
@property (nonatomic, strong) NSArray<NSArray *> *contents;

/// 设置contents的图片资源路径
/// 如不设置直接获取Assets中的资源
@property (nonatomic, copy) NSString *contentImagePath;
/// 设置contents的文字资源路径
/// 如不设置直接获取Localizable中的资源
@property (nonatomic, copy) NSString *contentTitlePath;

@property (nonatomic, copy) void(^selectContent)(NSInteger itemIndex, NSInteger contentIndex);

- (void)show;
- (void)hide;
- (BOOL)isShow;
- (NSArray<NSNumber *> *)getItemSelectedContentIndexs;

@end

NS_ASSUME_NONNULL_END
