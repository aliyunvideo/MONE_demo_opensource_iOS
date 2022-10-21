//
//  AUILiveLinkMicSelectRoleView.h
//  AUILiveLinkMic
//
//  Created by ISS013602000846 on 2022/8/1.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AUILiveLinkMicSelectRoleType) {
    AUILiveLinkMicSelectRoleTypeNone = 0,   // 未选择
    AUILiveLinkMicSelectRoleTypeAnchor,     // 主播
    AUILiveLinkMicSelectRoleTypeAudience,   // 观众
};

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveLinkMicSelectRoleView : UIView

@property (nonatomic, copy) void(^selectRole)(AUILiveLinkMicSelectRoleType roleType);

@end

NS_ASSUME_NONNULL_END
