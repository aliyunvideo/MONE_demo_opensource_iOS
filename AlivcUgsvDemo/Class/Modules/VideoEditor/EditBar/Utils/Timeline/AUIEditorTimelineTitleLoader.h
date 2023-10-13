//
//  AUIEditorTimelineTitleLoader.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/17.
//

#import <UIKit/UIKit.h>
#import <AUIUgsvCom/AUIUgsvCom.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIEditorTimelineTitleView : UIView

@property (nonatomic, strong, readonly) UILabel *textView;
@property (nonatomic, assign) UIEdgeInsets textInsets;
@property (nonatomic, assign) CGRect textFrame;

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, assign) UIEdgeInsets imageInsets;

+ (AUIEditorTimelineTitleView *)textView:(NSString *)title;
+ (AUIEditorTimelineTitleView *)imageView:(NSString *)path;
+ (AUIEditorTimelineTitleView *)videoDurationView:(NSTimeInterval)duration;

@end

@interface AUIEditorTimelineTitleLoader : AUITrackerTitleViewLoader

- (instancetype)initWithTitleView:(AUIEditorTimelineTitleView *)titleView;

@property (nonatomic, strong, readonly) AUIEditorTimelineTitleView *titleView;

@end

NS_ASSUME_NONNULL_END
