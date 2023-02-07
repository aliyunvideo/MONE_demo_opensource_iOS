//
//  PluginAudio.h
//  pluginAliDenoise
//
//  Created by sqummy on 2021/03/03.
//  Copyright © 2021. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pluginAliDenoise : NSObject
/**
* @brief AliRTCSDK call this for creat plugin
* @param name plugin name
* @param type plugin type
* @param pluginManager plugin manager
*/
- (void *)GetAliRTCPluginInterface:(NSString *)name
                              type:(NSNumber *)type
                     pluginManager:(const void *)pluginManager;
@end

