//
//  AUIPhotoPickerTabView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/27.
//

#import "AUIFoundation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIPhotoPickerTabType) {
    AUIPhotoPickerTabTypeAll,
    AUIPhotoPickerTabTypeVideo,
    AUIPhotoPickerTabTypeImage,
};

@interface AUIPhotoPickerTabView : UIView

@property (nonatomic, assign, readonly) AUIPhotoPickerTabType tabType;
- (instancetype)initWithFrame:(CGRect)frame withTabChangedBlock:(void (^)(AUIPhotoPickerTabType type))tabChangedBlock;

@end

NS_ASSUME_NONNULL_END
