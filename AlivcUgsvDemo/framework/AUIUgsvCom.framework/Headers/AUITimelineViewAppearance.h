//
//  AUITimelineViewAppearance.h
//  AUIUgsvCom
//
//  Created by Bingo on 2022/8/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUITimelineViewAppearance : NSObject

+ (AUITimelineViewAppearance *)defaultAppearcnce;

// #FCFCFD 1.0
@property (nullable, nonatomic, copy) UIColor *selectionViewColor;
@property (nullable, nonatomic, strong) UIImage *selectionViewLeftImage;
@property (nullable, nonatomic, strong) UIImage *selectionViewRightImage;

// #FCFCFD 1.0
@property (nullable, nonatomic, copy) UIColor *transitionIconViewBackgroundColor;
// #1C1E22 0.4
@property (nullable, nonatomic, copy) UIColor *transitionIconViewFillColor;

// #FCFCFD 0.2
@property (nullable, nonatomic, copy) UIColor *trackerThumbnailCellBackgroundColor;

// #747A8C 1.0
@property (nullable, nonatomic, copy) UIColor *trackerTimeCellColor;
// #FCFCFD 1.0
@property (nullable, nonatomic, copy) UIColor *timeIndicatorCellColor;


@end

NS_ASSUME_NONNULL_END
