//
//  AUIAsyncImageGeneratorAudio.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUIAsyncImageGeneratorProtocol.h"
#import <AVFoundation/AVFoundation.h>

@interface AUIAsyncImageGeneratorAudio : NSObject<AUIAsyncImageGeneratorProtocol>

- (instancetype)initWithPath:(NSString *)filePath;

+ (void)fetchAudioDBData:(AVURLAsset *)audioAsset
              sampleRate:(UInt32)sampleRate
               completed:(void(^)(NSData *dbData,
                                  UInt32 dbRate,
                                  Float32 normalizeMax,
                                  UInt32 channelCount,
                                  NSError *error))completed;
@end
