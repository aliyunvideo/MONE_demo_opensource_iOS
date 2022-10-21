//
//  AUIRecorderCameraWrapper.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import <UIKit/UIKit.h>
#import "AlivcUgsvSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class AUIRecorderCameraWrapper;
@protocol AUIRecorderCameraWrapperDelegate <NSObject>
- (void) onAUIRecorderCameraWrapper:(AUIRecorderCameraWrapper *)camera torchEnabled:(BOOL)torchEnabled;
@end

@interface AUIRecorderCameraWrapper : UIView
@property (nonatomic, weak) id<AUIRecorderCameraWrapperDelegate> delegate;
@property (nonatomic, readonly) id<AliyunCameraRecordController> cameraController;
@property (nonatomic, assign) BOOL torchOpened;
@property (nonatomic, readonly) BOOL torchEnabled;
- (instancetype) initWithCameraController:(id<AliyunCameraRecordController>)controller;

- (void) switchCameraPosition;
- (void) takePhoto;
@end

NS_ASSUME_NONNULL_END
