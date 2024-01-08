//
//  AUIUgsvMoreViewController.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/13.
//

#import "AUIUgsvMoreViewController.h"
#import "AUIUgsvMacro.h"
#import "AUIUgsvPath.h"

#import "AlivcUgsvSDKHeader.h"
#import "AUIUgsvOpenModuleHelper.h"
#import "AUIUgsvParamsViewController.h"
#import "AUIUgsvInfoViewController.h"

typedef NS_ENUM(NSUInteger, AUIUgsvMoreEntranceType) {
    AUIUgsvMoreEntranceTypePublish,
    AUIUgsvMoreEntranceTypeRecord,
    AUIUgsvMoreEntranceTypeEdit,
    AUIUgsvMoreEntranceTypeCrop,
    AUIUgsvMoreEntranceTypeMixRecord,
};

@interface AUIUgsvPublishParamInfo (ParamBulder)
- (void)buildParam:(AUIUgsvParamBuilder *)builder;
- (void)buildParamWithGroup:(AUIUgsvParamGroupBuilder *)group;
@end

@implementation AUIUgsvPublishParamInfo (ParamBulder)
- (void)buildParam:(AUIUgsvParamBuilder *)builder {
    [self buildParamWithGroup:builder.group(@"Other", AUIUgsvGetString(@"其他参数"))];
}
- (void)buildParamWithGroup:(AUIUgsvParamGroupBuilder *)group {
    group
        .switchItem(@"NeedToPublish", AUIUgsvGetString(@"合成后发布到云端")).KVC(self, @"needToPublish")
        .switchItem(@"SaveToAlbum", AUIUgsvGetString(@"合成后保存到相册")).KVC(self, @"saveToAlbum");
}
@end


@implementation AUIUgsvMoreViewController


- (instancetype)init {
    
    AVCommonListItem *item1 = [AVCommonListItem new];
    item1.title = AUIUgsvGetString(@"自定义拍摄");
    item1.info = AUIUgsvGetString(@"通过自定义参数体验拍摄功能");
    item1.icon = AUIUgsvGetImage(@"ic_ugsv_recorder");
    item1.tag = AUIUgsvMoreEntranceTypeRecord;
    
    AVCommonListItem *item2 = [AVCommonListItem new];
    item2.title = AUIUgsvGetString(@"自定义编辑");
    item2.info = AUIUgsvGetString(@"通过自定义参数体验编辑功能");
    item2.icon = AUIUgsvGetImage(@"ic_ugsv_editor");
    item2.tag = AUIUgsvMoreEntranceTypeEdit;
    
    AVCommonListItem *item3 = [AVCommonListItem new];
    item3.title = AUIUgsvGetString(@"自定义裁剪");
    item3.info = AUIUgsvGetString(@"通过自定义参数体验裁剪功能");
    item3.icon = AUIUgsvGetImage(@"ic_ugsv_clipper");
    item3.tag = AUIUgsvMoreEntranceTypeCrop;
    
    AVCommonListItem *item4 = [AVCommonListItem new];
    item4.title = AUIUgsvGetString(@"发布");
    item4.info = AUIUgsvGetString(@"从相册选择一个视频文件上传到云端");
    item4.icon = AUIUgsvGetImage(@"ic_ugsv_recorder");
    item4.tag = AUIUgsvMoreEntranceTypePublish;
    
    AVCommonListItem *item5 = [AVCommonListItem new];
    item5.title = AUIUgsvGetString(@"自定义合拍");
    item5.info = AUIUgsvGetString(@"通过自定义参数体验合拍功能");
    item5.icon = AUIUgsvGetImage(@"ic_ugsv_mix_recorder");
    item5.tag = AUIUgsvMoreEntranceTypeMixRecord;
    
    NSArray *list = @[item1, item5, item2, item3, item4];
    
    self = [super initWithItemList:list];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.hiddenMenuButton = YES;
    self.titleView.text = AUIUgsvGetString(@"更多");
}

- (void)onMenuClicked:(UIButton *)sender {
    AUIUgsvInfoViewController *infoVC = [AUIUgsvInfoViewController new];
    [self.navigationController pushViewController:infoVC animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AVCommonListItem *item = [self.itemList objectAtIndex:indexPath.row];
    switch (item.tag) {
        case AUIUgsvMoreEntranceTypePublish:
        {
            [AUIUgsvOpenModuleHelper openPickerToPublish:self];
        }
            break;
        case AUIUgsvMoreEntranceTypeRecord:
        {
            [self openRecorderConfig];
        }
            break;
        case AUIUgsvMoreEntranceTypeEdit:
        {
            [self openEditorConfig];
        }
            break;
        case AUIUgsvMoreEntranceTypeCrop:
        {
            [self openClipperConfig];
        }
            break;
        case AUIUgsvMoreEntranceTypeMixRecord:
        {
            [self openMixRecorderConfig];
        }
            break;
        default:
            break;
    }
}

- (void)openRecorderConfig {
    AUIRecorderConfig *config = [AUIRecorderConfig new];
    AUIUgsvParamBuilder *builder = config.paramBuilder;
    builder.lastSwitch.onValueDidChange(^(id  _Nullable oldValue, id  _Nullable curValue) {
        AUIUgsvParamItemSwitch *enterEditor = (AUIUgsvParamItemSwitch *)[builder findParamItemWithName:@"EnterEditor"];
        if (!enterEditor) {
            return;
        }
        BOOL isMerge = ((NSNumber *)curValue).boolValue;
        enterEditor.editabled = isMerge;
        if (!isMerge) {
            enterEditor.isOn = YES;
        }
    });
#ifndef USING_SVIDEO_BASIC
    builder.lastGroup
        .switchItem(@"EnterEditor", AUIUgsvGetString(@"进入编辑"))
            .editabled(config.mergeOnFinish)
            .defaultValue(!config.mergeOnFinish);
#endif // USING_SVIDEO_BASIC
    
    AUIUgsvPublishParamInfo *publishInfo = [AUIUgsvPublishParamInfo new];
    [publishInfo buildParamWithGroup:builder.lastGroup];

    AUIUgsvParamsViewController *paramController = [AUIUgsvParamsViewController new];
    paramController.titleText = AUIUgsvGetString(@"录制参数");
    paramController.confirmText = AUIUgsvGetString(@"开启录制");
    paramController.paramWrapper = builder.paramWrapper;
    
    __weak typeof(self) weakSelf = self;
    paramController.onConfirm = ^(AUIUgsvParamsViewController *controller){
        BOOL enterEdit = [builder.paramValues av_boolValueForKey:@"EnterEditor"];
        [AUIUgsvOpenModuleHelper openRecorder:weakSelf config:config enterEdit:enterEdit publishParam:publishInfo];
    };
    [self.navigationController pushViewController:paramController animated:YES];
}

- (void)openEditorConfig {
    AUIVideoOutputParam *param = [AUIVideoOutputParam Portrait720P];
    AUIUgsvParamBuilder *builder = param.paramBuilder;

    AUIUgsvPublishParamInfo *publishInfo = [AUIUgsvPublishParamInfo new];
    [publishInfo buildParam:builder];

    AUIUgsvParamsViewController *paramController = [AUIUgsvParamsViewController new];
    paramController.titleText = AUIUgsvGetString(@"编辑参数");
    paramController.confirmText = AUIUgsvGetString(@"进入编辑");
    paramController.paramWrapper = builder.paramWrapper;
    
    __weak typeof(self) weakSelf = self;
    paramController.onConfirm = ^(AUIUgsvParamsViewController *controller){
        [AUIUgsvOpenModuleHelper openEditor:weakSelf param:param publishParam:publishInfo];
    };
    [self.navigationController pushViewController:paramController animated:YES];
}

- (void)openClipperConfig {
    AUIVideoOutputParam *param = [AUIVideoOutputParam Portrait720P];
    AUIUgsvParamBuilder *builder = param.paramBuilderWithoutAudioParam;
    
    AUIUgsvPublishParamInfo *publishInfo = [AUIUgsvPublishParamInfo new];
    [publishInfo buildParam:builder];
    
    AUIUgsvParamsViewController *paramController = [AUIUgsvParamsViewController new];
    paramController.titleText = AUIUgsvGetString(@"裁剪参数");
    paramController.confirmText = AUIUgsvGetString(@"进入裁剪");
    paramController.paramWrapper = builder.paramWrapper;
    
    __weak typeof(self) weakSelf = self;
    paramController.onConfirm = ^(AUIUgsvParamsViewController *controller){
        [AUIUgsvOpenModuleHelper openClipper:weakSelf param:param publishParam:publishInfo];
    };
    [self.navigationController pushViewController:paramController animated:YES];
}

- (void)openMixRecorderConfig {
    AUIRecorderConfig *config = [AUIRecorderConfig new];
    config.horizontalResolution = AUIRecorderHorizontalResolution720;
    config.resolutionRatio = AUIRecorderResolutionRatio_1_1;
    config.isUsingAEC = YES;
    AUIUgsvParamBuilder *builder = config.mixRecordParamBuilder;
    [builder changeLastGroupWithName:@"OnFinish"];
    builder.lastGroup
        .switchItem(@"EnterEditor", AUIUgsvGetString(@"进入编辑"))
            .editabled(config.mergeOnFinish)
            .defaultValue(!config.mergeOnFinish);
    [builder findParamItemWithName:@"NeedMerge"].onValueDidChanged = ^(id  _Nullable oldValue, id  _Nullable curValue) {
        AUIUgsvParamItemSwitch *enterEditor = (AUIUgsvParamItemSwitch *)[builder findParamItemWithName:@"EnterEditor"];
        if (!enterEditor) {
            return;
        }
        BOOL isMerge = ((NSNumber *)curValue).boolValue;
        enterEditor.editabled = isMerge;
        if (!isMerge) {
            enterEditor.isOn = YES;
        }
    };
    
    AUIUgsvPublishParamInfo *publishInfo = [AUIUgsvPublishParamInfo new];
    [publishInfo buildParamWithGroup:builder.lastGroup];

    AUIUgsvParamsViewController *paramController = [AUIUgsvParamsViewController new];
    paramController.titleText = AUIUgsvGetString(@"录制参数");
    paramController.confirmText = AUIUgsvGetString(@"开启录制");
    paramController.paramWrapper = builder.paramWrapper;
    
    __weak typeof(self) weakSelf = self;
    paramController.onConfirm = ^(AUIUgsvParamsViewController *controller){
        BOOL enterEdit = [builder.paramValues av_boolValueForKey:@"EnterEditor"];
        [AUIUgsvOpenModuleHelper openMixRecorder:weakSelf config:config enterEdit:enterEdit publishParam:publishInfo];
    };
    [self.navigationController pushViewController:paramController animated:YES];
}

@end
