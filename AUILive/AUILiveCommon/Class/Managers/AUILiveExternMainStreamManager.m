//
//  AUILiveExternMainStreamManager.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2023/2/9.
//  Copyright © 2023 TripleL. All rights reserved.
//

#import "AUILiveExternMainStreamManager.h"
#include <sys/time.h>
#import "AliveLiveDemoUtil.h"

#define TEST_EXTERN_YUV_BUFFER_SIZE 1280*720*3/2
#define TEST_EXTERN_PCM_BUFFER_SIZE 3200

#define TEST_EXTERN_YUV_DURATION 40000
#define TEST_EXTERN_PCM_DURATION 30000

@interface AUILiveExternMainStreamManager () {
    dispatch_source_t _streamingTimer;
    int _userVideoStreamHandle;
    int _userAudioStreamHandle;
    FILE*  _videoStreamFp;
    FILE*  _audioStreamFp;
    int64_t _lastVideoPTS;
    int64_t _lastAudioPTS;
    char yuvData[TEST_EXTERN_YUV_BUFFER_SIZE];
    char pcmData[TEST_EXTERN_PCM_BUFFER_SIZE];
}

@end

int64_t getCurrentTimeUsExternMainStream()
{
    uint64_t ret;
    struct timeval time;
    gettimeofday(&time, NULL);
    ret = time.tv_sec * 1000000ll + (time.tv_usec);
    
    return ret;
}

@implementation AUILiveExternMainStreamManager

- (void)addUserStream {
    if(!_streamingTimer) {
        
        _videoStreamFp = 0;
        _audioStreamFp = 0;
        _lastVideoPTS = 0;
        _lastAudioPTS = 0;

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _streamingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_streamingTimer,DISPATCH_TIME_NOW,10*NSEC_PER_MSEC, 0);
        dispatch_source_set_event_handler(_streamingTimer, ^{
            
            if(!_videoStreamFp) {
                NSString* userVideoPath = [AliveLiveDemoUtil getExternalStreamResourceSavePath];
                const char* video_path = [userVideoPath UTF8String];
                _videoStreamFp = fopen(video_path, "rb");
            }
            
            if(!_audioStreamFp) {
                NSString* userAudioPath = AUILiveCommonData(@"441.pcm");
                const char* audio_path = [userAudioPath UTF8String];
                _audioStreamFp = fopen(audio_path, "rb");
            }
            
            if(_videoStreamFp) {
                
                int64_t nowTime = getCurrentTimeUsExternMainStream();
                if(nowTime  - _lastVideoPTS >= TEST_EXTERN_YUV_DURATION) {
                    
                    int dataSize = TEST_EXTERN_YUV_BUFFER_SIZE;
                    size_t size = fread((void *)yuvData, 1, dataSize, _videoStreamFp);
                    if(size<dataSize) {
                         fseek(_videoStreamFp,0,SEEK_SET);
                         size = fread((void *)yuvData, 1, dataSize, _videoStreamFp);
                    }
                    
                    if(size == dataSize) {
                        [self.livePusher sendVideoData:yuvData width:720 height:1280 size:dataSize pts:nowTime rotation:0];
                    }
                    _lastVideoPTS = nowTime;
                }
            }
            
            if(_audioStreamFp) {
                
                int64_t nowTime = getCurrentTimeUsExternMainStream();
                
                if(nowTime  - _lastAudioPTS >= TEST_EXTERN_PCM_DURATION) {
                    
                    int dataSize = TEST_EXTERN_PCM_BUFFER_SIZE;
                    size_t size =fread((void *)pcmData, 1, dataSize,  _audioStreamFp);
                    if(size<dataSize){
                        fseek(_audioStreamFp,0,SEEK_SET);
                    }
                    
                    if(size > 0) {
                        [self.livePusher sendPCMData:pcmData size:(int)size sampleRate:44100 channel:1 pts:nowTime];
                    }
                    _lastAudioPTS = nowTime;
                    
                }
            }
            
        });
        dispatch_resume(_streamingTimer);
    }
}

- (void)releaseUserStream {
    if(_streamingTimer) {
        dispatch_cancel(_streamingTimer);
        _streamingTimer = 0;
    }
    
    if(_videoStreamFp) {
        fclose(_videoStreamFp);
        _videoStreamFp = 0;
    }
    
    if(_audioStreamFp) {
        fclose(_audioStreamFp);
        _audioStreamFp = 0;
    }
}

@end
