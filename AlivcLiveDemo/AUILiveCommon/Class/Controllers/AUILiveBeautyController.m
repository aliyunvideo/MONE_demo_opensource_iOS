//
//  AUILiveBeautyController.m
//  AlivcLivePusherDemo
//
//  Created by zhangjc on 2022/5/7.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveBeautyController.h"
#import <CoreMotion/CoreMotion.h>

@interface AUILiveBeautyController ()

#ifdef ALIVC_LIVE_ENABLE_QUEENUIKIT
{
    uint8_t *_frameBuffer;
    size_t _frameBufferSize;
}

@property (nonatomic, strong) QueenEngine *beautyEngine;
@property (nonatomic, strong) AliyunQueenPanelController *beautyPanelController;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) int screenRotation;
@property (nonatomic, assign) kQueenImageFormat frameImageFormat;
@property (nonatomic, assign) int frameWidth;
@property (nonatomic, assign) int frameHeight;
@property (nonatomic, assign) int frameAngle;
@property (nonatomic, assign) BOOL runOnCustomThread;
#endif

@end

@implementation AUILiveBeautyController

#ifdef ALIVC_LIVE_ENABLE_QUEENUIKIT
+ (AUILiveBeautyController *)sharedInstance
{
    static AUILiveBeautyController *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[AUILiveBeautyController alloc] init];
        }
    });
    return sharedInstance;
}

- (void)setupBeautyController:(BOOL)processPixelBuffer
{
    [self initBeautyEngine:processPixelBuffer];
    self.beautyPanelController.queenEngine = self.beautyEngine;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.beautyPanelController selectCurrentBeautyEffect];
    });
}

- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(AlivcLivePushVideoFormat)videoFormat withPushOrientation:(AlivcLivePushOrientation)pushOrientation
{
    if (!self.beautyEngine)
    {
        return;
    }
    
    int screenRotation = 0;
    if (pushOrientation == AlivcLivePushOrientationLandscapeLeft)
    {
        screenRotation = -90;
    }
    else if (pushOrientation == AlivcLivePushOrientationLandscapeRight)
    {
        screenRotation = 90;
    }

    size_t bufferSize = 0;
    kQueenImageFormat imageFormat = kQueenImageFormatNV12;
    switch (videoFormat)
    {
        case AlivcLivePushVideoFormatRGB:
            imageFormat = kQueenImageFormatRGB;
            bufferSize = width * height * 3;
            break;
        case AlivcLivePushVideoFormatRGBA:
            imageFormat = kQueenImageFormatRGBA;
            bufferSize = width * height * 4;
            break;
        case AlivcLivePushVideoFormatYUVNV21:
            imageFormat = kQueenImageFormatNV21;
            bufferSize = width * height * 3 / 2;
            break;
        case AlivcLivePushVideoFormatYUVYV12:
        case AlivcLivePushVideoFormatYUVNV12:
            bufferSize = width * height * 3 / 2;
            break;
        default:
            NSAssert(false, @"Invalid Image Format For Beauty.");
            break;
    }
    @synchronized (self)
    {
        if (_frameBuffer)
        {
            free(_frameBuffer);
            _frameBuffer = NULL;
        }
        if (bufferSize > 0)
        {
            _frameBufferSize = bufferSize;
            _frameBuffer = (uint8_t *)malloc(bufferSize);
            memset(_frameBuffer, 0, bufferSize);
            memcpy(_frameBuffer, (uint8_t*)buffer, bufferSize);
            _frameImageFormat = imageFormat;
            _frameAngle = (_screenRotation + screenRotation + 360) % 360;
            _frameWidth = width;
            _frameHeight = height;
        }
    }
}

- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height
{
    if (!self.beautyEngine)
    {
        return textureID;
    }

    uint8_t *buffer = NULL;
    kQueenImageFormat frameImageFormat = kQueenImageFormatNV12;
    int frameWidth = 0;
    int frameHeight = 0;
    int frameAngle = 0;

    @synchronized (self)
    {
        if (_frameBuffer)
        {
            buffer = (uint8_t *)malloc(_frameBufferSize);
            memset(buffer, 0, _frameBufferSize);
            memcpy(buffer, _frameBuffer, _frameBufferSize);
            frameImageFormat = _frameImageFormat;
            frameAngle = _frameAngle;
            frameWidth = _frameWidth;
            frameHeight = _frameHeight;

            free(_frameBuffer);
            _frameBuffer = NULL;
        }
    }

    if (buffer)
    {
        [self.beautyEngine updateInputDataAndRunAlg:buffer
                                      withImgFormat:frameImageFormat
                                          withWidth:frameWidth
                                         withHeight:frameHeight
                                         withStride:0
                                     withInputAngle:frameAngle
                                    withOutputAngle:frameAngle
                                       withFlipAxis:0];
        free(buffer);
        buffer = NULL;
    }

    QETextureData* textureData = [[QETextureData alloc] init];
    textureData.inputTextureID = textureID;
    textureData.width = width;
    textureData.height = height;
    kQueenResultCode result = [self.beautyEngine processTexture:textureData];
    NSLog(@"\n\n width:%d, height:%d, inputTextureID:%d, outputTextureID:%d.\n\n", width, height, textureID, textureData.outputTextureID);
    if (result != kQueenResultCodeOK)
    {
        return textureID;
    }
    return textureData.outputTextureID;
}

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withPushOrientation:(AlivcLivePushOrientation)pushOrientation
{
    if (!self.beautyEngine)
    {
        return NO;
    }

    if (pixelBufferRef)
    {
        int screenRotation = 0;
        if (pushOrientation == AlivcLivePushOrientationLandscapeLeft)
        {
            screenRotation = 90;
        }
        else if (pushOrientation == AlivcLivePushOrientationLandscapeRight)
        {
            screenRotation = -90;
        }

        int motionScreenRotation = _screenRotation;
        if (_screenRotation == 90)
        {
            motionScreenRotation = 270;
        }
        else if (_screenRotation == 270)
        {
            motionScreenRotation = 90;
        }
        int angle = (motionScreenRotation + screenRotation + 360) % 360;

        QEPixelBufferData *bufferData = [QEPixelBufferData new];
        bufferData.bufferIn = bufferData.bufferOut = pixelBufferRef;
        bufferData.inputAngle = bufferData.outputAngle = angle;
        kQueenResultCode result = kQueenResultCodeUnKnown;
        if (_runOnCustomThread)
        {
            result = [self.beautyEngine processPixelBuffer:bufferData];
        }
        else
        {
            @synchronized (self)
            {
                result = [self.beautyEngine processPixelBuffer:bufferData];
            }
        }
        if (result == kQueenResultCodeOK)
        {
            return YES;
        }
    }
    return NO;
}

- (void)destroyBeautyController
{
    @synchronized (self)
    {
        if (_frameBuffer)
        {
            free(_frameBuffer);
            _frameBuffer = NULL;
        }
    }
    if (_runOnCustomThread)
    {
        [self destroyBeautyEngine];
    }
    else
    {
        @synchronized (self)
        {
            [self destroyBeautyEngine];
        }
    }
}

- (void)setupBeautyControllerUIWithView:(UIView *)view
{
    [self initMotionManager];
    if (view)
    {
        [self initBeautyConfigPanel:view];
    }
}

- (void)showPanel:(BOOL)animated
{
    if (!self.beautyPanelController)
    {
        return;
    }
    
    [self.beautyPanelController showPanel:animated];
}

- (void)destroyBeautyControllerUI
{
    [self destroyMotionManager];
    [self destroyBeautyConfigPanel];
}

#pragma mark - Engine

- (void)initBeautyEngine:(BOOL)withContext
{
    if (self.beautyEngine)
    {
        return;
    }
    
    QueenEngineConfigInfo *configInfo = [[QueenEngineConfigInfo alloc] init];
    configInfo.withContext = withContext;
    if (withContext)
    {
        configInfo.runOnCustomThread = NO;
    }
    _runOnCustomThread = configInfo.runOnCustomThread;
    configInfo.autoSettingImgAngle = NO;
    self.beautyEngine = [[QueenEngine alloc] initWithConfigInfo:configInfo];
}

- (void)destroyBeautyEngine
{
    if (self.beautyEngine)
    {
        [self.beautyEngine destroyEngine];
        self.beautyEngine = nil;
    }
}

#pragma mark - Panel

- (void)initBeautyConfigPanel:(UIView *)view
{
    if (self.beautyPanelController)
    {
        return;
    }
    self.beautyPanelController = [[AliyunQueenPanelController alloc] initWithParentView:view];
    self.beautyPanelController.queenEngine = self.beautyEngine;
    [self.beautyPanelController selectDefaultBeautyEffect];
}

- (void)destroyBeautyConfigPanel
{
    if (self.beautyPanelController)
    {
        [self.beautyPanelController dismiss];
        self.beautyPanelController = nil;
    }
}

#pragma mark - Gravity Motion

- (void)initMotionManager
{
    if (self.motionManager)
    {
        return;
    }
    _screenRotation = 0;
    
    self.motionManager = [[CMMotionManager alloc] init];
    if (self.motionManager.accelerometerAvailable)
    {
        self.motionManager.accelerometerUpdateInterval = 0.1f;
        __weak typeof(self) weakSelf = self;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData* accelerometerData, NSError* error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf.motionManager) {
                CMAccelerometerData* newestAccel = strongSelf.motionManager.accelerometerData;
                double accelerationX = newestAccel.acceleration.x;
                double accelerationY = newestAccel.acceleration.y;
                double ra = atan2(-accelerationY, accelerationX);
                double degree = ra * 180 / M_PI;
                if (degree >= -105 && degree <= -75) {
                    //NSLog(@"@keria motion: %f, 倒立", degree);
                    _screenRotation = 180;
                } else if (degree >= -15 && degree <= 15) {
                    //NSLog(@"@keria motion: %f, 右转", degree);
                    _screenRotation = 90;
                } else if (degree >= 75 && degree <= 105) {
                    //NSLog(@"@keria motion: %f, 正立", degree);
                    _screenRotation = 0;
                } else if (degree >= 165 || degree <= -165) {
                    //NSLog(@"@keria motion: %f, 左转", degree);
                    _screenRotation = 270;
                }
            }
        }];
    }
}

- (void)destroyMotionManager
{
    if (self.motionManager)
    {
        [self.motionManager stopAccelerometerUpdates];
        self.motionManager = nil;
    }
}
#endif

@end

