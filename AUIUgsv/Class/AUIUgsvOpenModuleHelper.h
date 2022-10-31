//
//  AUIUgsvOpenModuleHelper.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import <UIKit/UIKit.h>
#import "AUIVideoOutputParam.h"
#import "AUIRecorderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIUgsvPublishParamInfo : NSObject
@property (nonatomic, assign) BOOL saveToAlbum;
@property (nonatomic, assign) BOOL needToPublish;
+ (AUIUgsvPublishParamInfo *) InfoWithSaveToAlbum:(BOOL)saveToAlbum needToPublish:(BOOL)needToPublish;
@end

@interface AUIUgsvOpenModuleHelper : NSObject

+ (void)openRecorder:(UIViewController *)currentVC
              config:(nullable AUIRecorderConfig *)config
           enterEdit:(BOOL)enterEdit
        publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam;

+ (void)openEditor:(UIViewController *)currentVC
             param:(AUIVideoOutputParam *)param
      publishParam:(AUIUgsvPublishParamInfo *)publishParam;

+ (void)openClipper:(UIViewController *)currentVC
              param:(nullable AUIVideoOutputParam *)param
       publishParam:(AUIUgsvPublishParamInfo *)publishParam;

+ (void)openPickerToPublish:(UIViewController *)currentVC;

@end

NS_ASSUME_NONNULL_END
