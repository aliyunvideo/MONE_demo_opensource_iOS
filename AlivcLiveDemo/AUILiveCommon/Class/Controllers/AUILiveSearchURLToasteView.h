//
//  AUILiveSearchURLToasteView.h
//  AUILiveCommon
//
//  Created by ISS013602000846 on 2022/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveSearchURLToasteView : UIView

@property (nonatomic, copy) void(^goBack)(NSString *url);
@property (nonatomic, copy) dispatch_block_t enterQRPage;
@property (nonatomic, copy) dispatch_block_t exitQRPage;

- (void)show;

@end

NS_ASSUME_NONNULL_END
