//
//  AUITransitionModel.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/23.
//

#import "AUIResourceModel.h"
#import "AlivcUgsvSDKHeader.h"


typedef NS_ENUM(NSInteger, TransitionType){
    TransitionTypeNull = 0,
    TransitionTypeMoveUp,
    TransitionTypeMoveDown,
    TransitionTypeMoveLeft,
    TransitionTypeMoveRight,
    TransitionTypeShuffer,
    TransitionTypeFade,
    TransitionTypeCircle,
    TransitionTypeStar,
};

NS_ASSUME_NONNULL_BEGIN

@interface AUITransitionModel : AUIResourceModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) TransitionType type;
@property (nonatomic, strong) NSString *iconName;


- (instancetype)initWithType:(TransitionType)type;

@end

@interface AUITransitionHelper : NSObject


+ (NSArray<AUITransitionModel *> *)dataList;

+ (TransitionType)typeWithAepObject:(AEPTransitionEffect *)aep;
+ (AliyunTransitionEffect *)transitionEffectWithType:(TransitionType)type;

@end


NS_ASSUME_NONNULL_END
