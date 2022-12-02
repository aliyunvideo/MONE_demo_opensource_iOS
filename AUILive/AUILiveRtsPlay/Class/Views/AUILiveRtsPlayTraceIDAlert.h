//
//  AUILiveRtsPlayTraceIDAlert.h
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/8/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRtsPlayTraceIDAlert : UIView

+ (void)show:(NSString *)traceID playUrl:(NSString *)playUrl view:(UIView *)view copyHandle:(void(^)(void))copyHandle;

@end

NS_ASSUME_NONNULL_END
