//
//  AUIPhotoPickerTitleView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/26.
//

#import "AUIFoundation.h"

NS_ASSUME_NONNULL_BEGIN



@interface AUIPhotoPickerTitleView : UIView

- (instancetype)initWithSelectChangedBlock:(void (^)(BOOL))selectChangedBlock;

- (void)updateTitle:(NSString *)title;
- (void)setSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
