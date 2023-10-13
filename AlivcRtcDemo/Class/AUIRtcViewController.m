//
//  AUIRtcViewController.m
//  AlivcRtcDemo
//
//  Created by Bingo on 2023/7/19.
//

#import "AUIRtcViewController.h"

//#define ENABLE_AUI_CALL
#ifdef ENABLE_AUI_CALL
@import AUICall;
#endif

#import "AUIRtcMacro.h"

typedef NS_ENUM(NSUInteger, AUIRtcModuleIndex) {
    AUIRtcModuleIndexCall1V1 = 1,
    AUIRtcModuleIndexCallNVN,
};

@interface AUIRtcViewController ()

@end

@implementation AUIRtcViewController

- (instancetype)init {
    AVCommonListItem *item1 = [AVCommonListItem new];
    item1.title = @"1v1音视频通话";
    item1.info = @"";
    item1.icon = RtcImage(@"ic_call_1v1");
    item1.tag = AUIRtcModuleIndexCall1V1;
    
    AVCommonListItem *item2 = [AVCommonListItem new];
    item2.title = @"多人音视频通话";
    item2.info = @"";
    item2.icon = RtcImage(@"ic_call_nvn");
    item2.tag = AUIRtcModuleIndexCallNVN;
    
    NSArray *list = @[item1, item2];

   self = [super initWithItemList:list];
   if (self) {
   }
   return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenMenuButton = YES;
    self.titleView.text = @"互动直播";
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AVCommonListItem *item = [self.itemList objectAtIndex:indexPath.row];
    if (item.tag == AUIRtcModuleIndexCall1V1) {
        [self openCall1V1];
    }
    else if (item.tag == AUIRtcModuleIndexCallNVN) {
        [self openCallNVN];
    }
}

- (void)openCall1V1 {
    // 请参考：https://help.aliyun.com/document_detail/2568023.html
#ifdef ENABLE_AUI_CALL
    AUICall1V1MainViewController *vc = [[AUICall1V1MainViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
#else
    [AVAlertController show:@"当前App未集成AUICall"];
#endif
}

- (void)openCallNVN {
    // 请参考：https://help.aliyun.com/document_detail/2568023.html
#ifdef ENABLE_AUI_CALL
    AUICallNVNMainViewController *vc = [[AUICallNVNMainViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
#else
    [AVAlertController show:@"当前App未集成AUICall"];
#endif
}


@end
