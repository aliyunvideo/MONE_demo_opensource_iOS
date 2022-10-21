//
//  AUIVideoEditorBaseEffectView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUIVideoEditorBaseEffectInfo <NSObject>
@property (nonatomic, readonly) NSInteger effectType;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *icon;
@optional
@property (nonatomic, readonly) BOOL flagModify;
@end

typedef void(^OnBaseEffectSelectDidChanged)(id<AUIVideoEditorBaseEffectInfo>);
@interface AUIVideoEditorBaseEffectView : UIView
@property (nonatomic, readonly) id<AUIVideoEditorBaseEffectInfo> current;
@property (nonatomic, copy) NSArray<id<AUIVideoEditorBaseEffectInfo>> *infos;
@property (nonatomic, copy) OnBaseEffectSelectDidChanged onSelectDidChanged;

- (BOOL)selectWithType:(NSInteger)type;
@end

NS_ASSUME_NONNULL_END
