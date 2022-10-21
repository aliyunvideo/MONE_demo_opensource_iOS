//
//  AlivcPlayerPlayPluginManager.m
//  AFNetworking
//
//  Created by mengyehao on 2021/7/2.
//

#import "AlivcPlayerPlayPluginManager.h"
#import "AlivcPlayerBasePlugin.h"


@interface AlivcPlayerPlayPluginManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *,AlivcPlayerBasePlugin *> *pluginDict;

@end

@implementation AlivcPlayerPlayPluginManager


- (NSMutableDictionary<NSString *,AlivcPlayerBasePlugin *> *)pluginDict
{
    if (!_pluginDict) {
        _pluginDict = [[NSMutableDictionary alloc] init];
    }
    return _pluginDict;
}

- (void)registerPlugin:(NSString *)pluginId
{
    if (pluginId) {
        
        
        AlivcPlayerBasePlugin *plugin = [[NSClassFromString(pluginId) alloc] init];
        if (![self.pluginDict.allKeys containsObject:pluginId]) {
            [self.pluginDict setObject:plugin forKey:pluginId];
            [plugin onInstall];
        }
    }
}

- (void)unRegisterPlugin:(NSString *)pluginId
{
    if (pluginId) {
            AlivcPlayerBasePlugin *plugin = [self.pluginDict objectForKey:pluginId];
            [self.pluginDict removeObjectForKey:pluginId];
            [plugin onUnInstall];
        
    }
}

- (BOOL)containsPlugin:(NSString *)pluginId
{
    if (pluginId) {
        return [self.pluginDict.allKeys containsObject:pluginId];
    }
    return NO;
}

- (AlivcPlayerBasePlugin *)pluginWithId:(NSString *)pluginId
{
    AlivcPlayerBasePlugin *plugin = nil;
    if (pluginId) {
        plugin = [self.pluginDict objectForKey:pluginId];
    }
    
    return plugin;
}

- (NSArray< NSString *>*)currentPluginIDList
{
    return self.pluginDict.allKeys;
}

- (NSArray *)getAllPlugins
{
    return self.pluginDict.allValues;
}

- (void)removeAllPlugins
{
    [self.pluginDict.allValues enumerateObjectsUsingBlock:^(AlivcPlayerBasePlugin * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj onUnInstall];
    }];
    [self.pluginDict removeAllObjects];
}


- (void)registerLazyPlugin:(NSString *)pluginId
{
    
}

- (void)registerPluginDelayPlugins
{
    
}

@end
