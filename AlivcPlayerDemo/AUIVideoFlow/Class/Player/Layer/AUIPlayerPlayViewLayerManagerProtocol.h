//
//  AUIPlayerPlayViewLayerManagerProtocol.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/8.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,  APPlayViewLayerLevel) {
    APPlayViewLayerLevelPlayer,
    APPlayViewLayerLevelLow,
    APPlayViewLayerLevelMiddle,
    APPlayViewLayerLevelHigh,
};

@protocol AUIPlayerPlayViewLayerManagerProtocol <NSObject>

- (UIView *)playContainView;
- (UIView *)viewAtLevel:(NSInteger)level;

@end


