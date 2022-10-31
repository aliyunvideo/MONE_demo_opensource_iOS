//
//  AUIPlayerPlayContainViewPluginInstallProtocol.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import <Foundation/Foundation.h>



@protocol AUIPlayerPlayContainViewPluginInstallProtocol <NSObject>

- (NSDictionary<NSString *, NSNumber*> *)pluginMap;
- (int)playscene;

@end

