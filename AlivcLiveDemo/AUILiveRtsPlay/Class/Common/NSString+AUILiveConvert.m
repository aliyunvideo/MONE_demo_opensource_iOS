//
//  NSString+AUILiveConvert.m
//  AUILiveRtsPlay
//
//  Created by ISS013602000846 on 2022/11/14.
//

#import "NSString+AUILiveConvert.h"

@implementation NSString (AUILiveConvert)

- (NSDictionary *)rts_toDictionary {
    if (self == nil) {
        return nil;
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSDictionary *)rts_paramsToDictionaryWithSeparator:(NSString*)split {
    if (self == nil) {
        return nil;
    }
    NSMutableDictionary *multiDic = @{}.mutableCopy;
    NSString *content = [self stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *arr = [content componentsSeparatedByString:@","];
    if (arr.count>0) {
        for (NSString *str in arr) {
            NSArray *kvArr = [str componentsSeparatedByString:split];
            if (kvArr.count==2) {
                [multiDic setValue:kvArr[1] forKey:kvArr[0]];
            }
            
        }
    }
    return multiDic;
}

@end
