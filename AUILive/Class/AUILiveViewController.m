//
//  AUILiveViewController.m
//  AlivcLivePusherDemo
//
//  Created by zzy on 2022/5/31.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "AUILiveViewController.h"
#import "AUILiveCameraPushModule.h"
#import "AUILiveRecordPushModule.h"
#import "AUILivePlayModule.h"
#import "AUILiveLinkMicModule.h"
#import "AUILivePKModule.h"

#define ITEMINDEX_PLACEHOLDER -1

@interface AUILiveViewController ()

@property (nonatomic, assign) NSInteger recordPushItemIndex;
@property (nonatomic, assign) NSInteger playItemIndex;
@property (nonatomic, assign) NSInteger linkMicItemIndex;
@property (nonatomic, assign) NSInteger pkItemIndex;

@end

@implementation AUILiveViewController

- (instancetype)init {
   NSMutableArray *list = [NSMutableArray array];
   
   AVCommonListItem *item1 = [AVCommonListItem new];
   item1.title = AlivcLiveString(@"Camera Push");
   item1.info = AlivcLiveString(@"The demonstration of the camera push");
   item1.icon = AlivcLiveImage(@"zhibo_ic_tuiliu");
   [list addObject:item1];
   
   if ([AUILiveRecordPushModule checkCanOpen]) {
       AVCommonListItem *item2 = [AVCommonListItem new];
       item2.title = AlivcLiveString(@"Record Push");
       item2.info = AlivcLiveString(@"The demonstration of the record push");
       item2.icon = AlivcLiveImage(@"zhibo_ic_luping");
       [list addObject:item2];
       self.recordPushItemIndex = 1;
   } else {
       self.recordPushItemIndex = ITEMINDEX_PLACEHOLDER;
   }

   AVCommonListItem *item3 = [AVCommonListItem new];
   item3.title = AlivcLiveString(@"Pull Play");
   item3.info = AlivcLiveString(@"The demonstration of the pull play");
   item3.icon = AlivcLiveImage(@"zhibo_ic_laliu");
   [list addObject:item3];
   if (self.recordPushItemIndex != ITEMINDEX_PLACEHOLDER) {
      self.playItemIndex = 2;
   } else {
      self.playItemIndex = 1;
   }
   
   if ([AUILiveLinkMicModule checkCanOpen]) {
       AVCommonListItem *item4 = [AVCommonListItem new];
       item4.title = AlivcLiveString(@"Link Mic");
       item4.info = AlivcLiveString(@"The demonstration of the link mic");
       item4.icon = AlivcLiveImage(@"zhibo_ic_linkmic");
       [list addObject:item4];
       self.linkMicItemIndex = self.playItemIndex + 1;
   } else {
       self.linkMicItemIndex = ITEMINDEX_PLACEHOLDER;
   }

   if ([AUILivePKModule checkCanOpen]) {
       AVCommonListItem *item5 = [AVCommonListItem new];
       item5.title = AlivcLiveString(@"PK");
       item5.info = AlivcLiveString(@"The demonstration of the PK");
       item5.icon = AlivcLiveImage(@"zhibo_ic_pk");
       [list addObject:item5];
       if (self.linkMicItemIndex != ITEMINDEX_PLACEHOLDER) {
           self.pkItemIndex = self.linkMicItemIndex + 1;
       } else {
           self.pkItemIndex = self.playItemIndex + 1;
       }
   } else {
       self.pkItemIndex = ITEMINDEX_PLACEHOLDER;
   }

   self = [super initWithItemList:list];
   if (self) {
   }
   return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenMenuButton = YES;
    self.titleView.text = AlivcLiveString(@"Live Demo");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        [self openCameraPush];
    } else if (indexPath.item == self.recordPushItemIndex) {
        [self openRecordPush];
    } else if (indexPath.item == self.playItemIndex) {
        [self openPlay];
    } else if (indexPath.item == self.linkMicItemIndex) {
        [self openLinkMic];
    } else if (indexPath.item == self.pkItemIndex) {
        [self openPK];
    }
}

- (void)openCameraPush {
    AUILiveCameraPushModule *module = [[AUILiveCameraPushModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openRecordPush {
    AUILiveRecordPushModule *module = [[AUILiveRecordPushModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openPlay {
    AUILivePlayModule *module = [[AUILivePlayModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openLinkMic {
    AUILiveLinkMicModule *module = [[AUILiveLinkMicModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openPK {
    AUILivePKModule *module = [[AUILivePKModule alloc] initWithSourceViewController:self];
    [module open];
}

@end
