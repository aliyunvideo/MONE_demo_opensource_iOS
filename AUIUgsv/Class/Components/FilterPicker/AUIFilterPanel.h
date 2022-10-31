//
//  AUIFilterPanel.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/13.
//

#import "AVBaseControllPanel.h"
#import "AUIFilterModel.h"
#import "AUIFilterView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnFilterSelectedChanged)(AUIFilterModel *);
typedef void(^FilterDataCallback)(NSError * _Nullable error, NSArray *data);
typedef void(^FilterDataFetcher)(FilterDataCallback cb);

@interface AUIFilterPanel : AVBaseControllPanel

@property (nonatomic, readonly) AUIFilterView *filterView;
@property (nonatomic, copy) OnFilterSelectedChanged onSelectedChanged;

- (instancetype)initWithFrame:(CGRect)frame dataFetcher:(FilterDataFetcher)dataFetcher;
- (void)selectFilter:(AUIFilterModel *)filter;

@end

NS_ASSUME_NONNULL_END
