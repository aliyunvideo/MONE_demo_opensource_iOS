//
//  AUIPlayerViewController.m
//  AlivcPlayerDemo
//
//  Created by zzy on 2022/5/26.
//

#import "AUIPlayerViewController.h"
#import "AUIVideoFlowModule.h"
#import "AUIVideoListModule.h"
#import "AUIVideoFullScreenModule.h"
// #import "AUIVideoCustomModule.h"

@interface AUIPlayerViewController ()

@end

@implementation AUIPlayerViewController

- (instancetype)init {
   AVCommonListItem *item1 = [AVCommonListItem new];
   item1.title = AlivcPlayerString(@"Video Flow");
   item1.info = AlivcPlayerString(@"The demonstration of the video flow");
   item1.icon = AlivcPlayerImage(@"bofangqi_ic_xinxi");
   
   AVCommonListItem *item2 = [AVCommonListItem new];
   item2.title = AlivcPlayerString(@"Video List");
   item2.info = AlivcPlayerString(@"The demonstration of the video list");
   item2.icon = AlivcPlayerImage(@"bofangqi_ic_chenjin");
   
   AVCommonListItem *item3 = [AVCommonListItem new];
   item3.title = AlivcPlayerString(@"Video Full Screen");
   item3.info = AlivcPlayerString(@"The demonstration of the video full screen");
   item3.icon = AlivcPlayerImage(@"bofangqi_ic_quanping");
   
//   AVCommonListItem *item4 = [AVCommonListItem new];
//   item4.title = AlivcPlayerString(@"Video Custom");
//   item4.info = AlivcPlayerString(@"The demonstration of the video custom");
//   item4.icon = AlivcPlayerImage(@"bofangqi_ic_zidingyi");
   NSArray *list = @[item1, item2, item3];
   
   self = [super initWithItemList:list];
   if (self) {
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   // Do any additional setup after loading the view.
   
   self.hiddenMenuButton = YES;
   self.titleView.text = AlivcPlayerString(@"Player Demo");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.item) {
        case 0:
        {
            [self openVideoFlow];
        }
            break;
        case 1:
        {
            [self openVideoList];
        }
            break;
        case 2:
        {
            [self openVideoFullScreen];
        }
            break;
//        case 3:
//        {
//            [self openVideoCustom];
//        }
//            break;
        default:
            break;
    }
}

- (void)openVideoFlow {
    AUIVideoFlowModule *module = [[AUIVideoFlowModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openVideoList {
    AUIVideoListModule *module = [[AUIVideoListModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openVideoFullScreen {
    AUIVideoFullScreenModule *module = [[AUIVideoFullScreenModule alloc] initWithSourceViewController:self];
    [module open];
}

//- (void)openVideoCustom {
//    AUIVideoCustomModule *module = [[AUIVideoCustomModule alloc] initWithSourceViewController:self];
//    [module open];
//}

@end
