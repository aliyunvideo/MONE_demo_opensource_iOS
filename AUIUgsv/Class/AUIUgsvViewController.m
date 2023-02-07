//
//  AUIUgsvViewController.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/21.
//

#import "AUIUgsvViewController.h"
#import "AUIUgsvMacro.h"
#import "AUIUgsvPath.h"

#import "AlivcUgsvSDKHeader.h"
#import "AUIUgsvMoreViewController.h"
#import "AUIUgsvParamsViewController.h"
#import "AUIUgsvOpenModuleHelper.h"

#import "AUIVideoTemplateListViewController.h"


typedef NS_ENUM(NSUInteger, AUIUgsvEntranceType) {
    AUIUgsvEntranceTypeRecorder,
    AUIUgsvEntranceTypeEditor,
    AUIUgsvEntranceTypeClipper,
    AUIUgsvEntranceTypeTemplate,
    AUIUgsvEntranceTypeMore
};

@interface AUIUgsvViewController ()
@end

@implementation AUIUgsvViewController

- (instancetype)init {
    AVCommonListItem *item1 = [AVCommonListItem new];
    item1.title = AUIUgsvGetString(@"Recorder");
    item1.info = AUIUgsvGetString(@"The demonstration of the recorder");
    item1.icon = AUIUgsvGetImage(@"ic_ugsv_recorder");
    item1.tag = AUIUgsvEntranceTypeRecorder;
    
    AVCommonListItem *item2 = [AVCommonListItem new];
    item2.title = AUIUgsvGetString(@"Editor");
    item2.info = AUIUgsvGetString(@"The demonstration of the editor");
    item2.icon = AUIUgsvGetImage(@"ic_ugsv_editor");
    item2.tag = AUIUgsvEntranceTypeEditor;
    
    AVCommonListItem *item3 = [AVCommonListItem new];
    item3.title = AUIUgsvGetString(@"Clipper");
    item3.info = AUIUgsvGetString(@"The demonstration of the clipper");
    item3.icon = AUIUgsvGetImage(@"ic_ugsv_clipper");
    item3.tag = AUIUgsvEntranceTypeClipper;
    
    AVCommonListItem *item4 = [AVCommonListItem new];
    item4.title = AUIUgsvGetString(@"剪同款");
    item4.info = AUIUgsvGetString(@"");
    item4.icon = AUIUgsvGetImage(@"ic_ugsv_more");
    item4.tag = AUIUgsvEntranceTypeTemplate;
    
    AVCommonListItem *item5 = [AVCommonListItem new];
    item5.title = AUIUgsvGetString(@"More");
    item5.info = AUIUgsvGetString(@"");
    item5.icon = AUIUgsvGetImage(@"ic_ugsv_more");
    item5.tag = AUIUgsvEntranceTypeMore;
    
    NSArray *list = @[item1, item2, item3, item4, item5];
    
    self = [super initWithItemList:list];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenMenuButton = YES;
    self.titleView.text = AUIUgsvGetString(@"Short video");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AVCommonListItem *item = [self.itemList objectAtIndex:indexPath.row];
    switch (item.tag) {
        case AUIUgsvEntranceTypeRecorder:
        {
            [self openRecorder];
        }
            break;
        case AUIUgsvEntranceTypeEditor:
        {
            [self openEditor];
        }
            break;
        case AUIUgsvEntranceTypeClipper:
        {
            [self openClipper];
        }
            break;
        case AUIUgsvEntranceTypeTemplate:
        {
            [self openTemplate];
        }
            break;
        case AUIUgsvEntranceTypeMore:
        {
            [self openMore];
        }
            break;
        default:
            break;
    }
}

- (void)openRecorder {
#ifdef USING_SVIDEO_BASIC
    AUIUgsvPublishParamInfo *publishInfo = [AUIUgsvPublishParamInfo InfoWithSaveToAlbum:YES needToPublish:YES];
    [AUIUgsvOpenModuleHelper openRecorder:self config:nil enterEdit:NO publishParam:publishInfo];
#else
    [AUIUgsvOpenModuleHelper openRecorder:self config:nil enterEdit:YES publishParam:nil];
#endif
}

- (void)openEditor {
    AUIUgsvPublishParamInfo *publishInfo = [AUIUgsvPublishParamInfo InfoWithSaveToAlbum:YES needToPublish:YES];
    [AUIUgsvOpenModuleHelper openEditor:self param:[AUIVideoOutputParam Portrait720P] publishParam:publishInfo];
}

- (void)openClipper {
    AUIUgsvPublishParamInfo *publishInfo = [AUIUgsvPublishParamInfo InfoWithSaveToAlbum:YES needToPublish:YES];
    [AUIUgsvOpenModuleHelper openClipper:self param:[AUIVideoOutputParam Portrait720P] publishParam:publishInfo];
}

- (void)openTemplate {
    if (![AliyunAETemplateManager canSupport]) {
        [AVAlertController show:@"当前机型不支持"];
        return;
    }
    AUIVideoTemplateListViewController *vc = [[AUIVideoTemplateListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openMore {
    AUIUgsvMoreViewController *vc = [[AUIUgsvMoreViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
