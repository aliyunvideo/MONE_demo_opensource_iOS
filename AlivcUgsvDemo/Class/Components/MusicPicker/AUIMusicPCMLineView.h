//
//  AUIMusicPCMLineView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIMusicPCMLineView : UIView
@property (nonatomic, readonly) NSArray<NSNumber *> *pcmData;
@property (nonatomic, assign) CGFloat realShowPercentage;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, assign) CGFloat normalizedBegin;
@property (nonatomic, assign) CGFloat normalizedCurrent;
@property (nonatomic, assign) CGFloat normalizedEnd;
- (instancetype)initWithFile:(NSString *)filePath;
- (instancetype)initWithPCMData:(NSArray *)pcmData;
- (void)refresh;
@end

NS_ASSUME_NONNULL_END
