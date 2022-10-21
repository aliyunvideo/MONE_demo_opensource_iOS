//
//  AUISegementView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/5/31.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface AUISegementView : UIView

@property (nonatomic, assign) NSUInteger selectedType;
@property (nonatomic, assign) CGFloat paddingX;
@property (nonatomic, assign) BOOL hideSeletedBomline;
@property (nonatomic, copy) void (^onSelectedChanged)(NSUInteger selectedType);

- (instancetype)initWithTitles:(NSArray<NSString *>*)titles;
@end

NS_ASSUME_NONNULL_END
