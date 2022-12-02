//
//  NSString+AUILiveConvert.h
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AUILiveConvert)

- (NSDictionary *)rts_toDictionary;
- (NSDictionary *)rts_paramsToDictionaryWithSeparator:(NSString*)split;

@end

NS_ASSUME_NONNULL_END
