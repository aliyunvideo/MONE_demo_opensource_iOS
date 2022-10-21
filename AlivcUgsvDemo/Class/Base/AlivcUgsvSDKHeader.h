//
//  AlivcUgsvSDKHeader.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#ifndef AlivcUgsvSDKHeader_h
#define AlivcUgsvSDKHeader_h

#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>
#elif __has_include(<AliVCSDK_Premium/AliVCSDK_Premium.h>)
#import <AliVCSDK_Premium/AliVCSDK_Premium.h>
#define INCLUDE_QUEEN 1
#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>
#elif __has_include(<AliVCSDK_UGCPro/AliVCSDK_UGCPro.h>)
#import <AliVCSDK_UGCPro/AliVCSDK_UGCPro.h>
#define INCLUDE_QUEEN 1
#elif __has_include(<AliyunVideoSDKPro/AliyunVideoSDKPro.h>)
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#elif __has_include(<AliyunVideoSDKBasic/AliyunVideoSDKBasic.h>)
#import <AliyunVideoSDKBasic/AliyunVideoSDKBasic.h>
#define USING_SVIDEO_BASIC 1
#endif


#if __has_include(<Queen/Queen.h>)
#import <Queen/Queen.h>
#define INCLUDE_QUEEN 1
#endif

#endif /* AlivcUgsvSDKHeader_h */
