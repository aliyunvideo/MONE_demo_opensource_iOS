//
//  AlivcPlayerPluginManagerProtocol.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/8.
//

#import <Foundation/Foundation.h>
@class AlivcPlayerBasePlugin;

@protocol AlivcPlayerPluginManagerProtocol <NSObject>

- (void)registerPlugin:(NSString *)pluginId;

- (void)unRegisterPlugin:(NSString *)pluginId;

- (BOOL)containsPlugin:(NSString *)pluginId;

- (AlivcPlayerBasePlugin *)pluginWithId:(NSString *)pluginId;

- (NSArray< NSString *>*)currentPluginIDList;

@end


