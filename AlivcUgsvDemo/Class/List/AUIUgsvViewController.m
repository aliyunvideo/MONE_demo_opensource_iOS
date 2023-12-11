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

typedef NS_ENUM(NSUInteger, AUIUgsvEntranceType) {
    AUIUgsvEntranceTypeRecorder,
    AUIUgsvEntranceTypeMixRecorder,
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
    item1.info = @"";
    item1.icon = AUIUgsvGetImage(@"ic_ugsv_recorder");
    item1.tag = AUIUgsvEntranceTypeRecorder;
    
    AVCommonListItem *item2 = [AVCommonListItem new];
    item2.title = AUIUgsvGetString(@"Editor");
    item2.info = @"";
    item2.icon = AUIUgsvGetImage(@"ic_ugsv_editor");
    item2.tag = AUIUgsvEntranceTypeEditor;
    
    AVCommonListItem *item3 = [AVCommonListItem new];
    item3.title = AUIUgsvGetString(@"Clipper");
    item3.info = @"";
    item3.icon = AUIUgsvGetImage(@"ic_ugsv_clipper");
    item3.tag = AUIUgsvEntranceTypeClipper;
    
    AVCommonListItem *item4 = [AVCommonListItem new];
    item4.title = AUIUgsvGetString(@"剪同款");
    item4.info = @"";
    item4.icon = AUIUgsvGetImage(@"ic_ugsv_template");
    item4.tag = AUIUgsvEntranceTypeTemplate;
    
    AVCommonListItem *item5 = [AVCommonListItem new];
    item5.title = AUIUgsvGetString(@"More");
    item5.info = @"";
    item5.icon = AUIUgsvGetImage(@"ic_ugsv_more");
    item5.tag = AUIUgsvEntranceTypeMore;
    
    AVCommonListItem *item6 = [AVCommonListItem new];
    item6.title = AUIUgsvGetString(@"合拍");
    item6.info = @"";
    item6.icon = AUIUgsvGetImage(@"ic_ugsv_mix_recorder");
    item6.tag = AUIUgsvEntranceTypeMixRecorder;
    
    NSArray *list = @[item1, item6, item2, item3, item4, item5];
    
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
        case AUIUgsvEntranceTypeMixRecorder: 
        {
            [self openMixRecorder];
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
    [AUIUgsvOpenModuleHelper openRecorder:self config:nil enterEdit:YES publishParam:nil];
}

- (void)openMixRecorder {
    [AUIUgsvOpenModuleHelper openMixRecorder:self config:nil enterEdit:YES publishParam:nil];
}

- (void)openEditor {
    [AUIUgsvOpenModuleHelper openEditor:self param:nil publishParam:nil];
}

- (void)openClipper {
    [AUIUgsvOpenModuleHelper openClipper:self param:nil publishParam:nil];
}

- (void)openTemplate {
    [AUIUgsvOpenModuleHelper openTemplateList:self];
}

- (void)openMore {
    AUIUgsvMoreViewController *vc = [[AUIUgsvMoreViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
