# AUIShortEpisode组件
阿里云 · AUIKits微短剧场景

## 代码结构
```
├── AUIShortEpisode   // AUI短剧组件
│   ├── Resources                         // 资源文件
│   ├── Source                            // 源代码
│   ├── AUIShortEpisode.podspec           // 本地pod文件
│   ├── README.md   // Readme   
|—— AUIFoundation     // AUI基础组件（[Github地址](https://github.com/aliyunvideo/MONE_demo_opensource_iOS/tree/main/AUIBaseKits/AUIFoundation)）
```

## 环境要求

- Xcode 12.0 及以上版本，推荐使用最新正式版本
- CocoaPods 1.9.3 及以上版本
- iOS版本10.0或以上版本的真机

## 前提条件

您已获取MediaBox音视频SDK的播放器的License授权和License Key。获取方法，请参见获取[License](https://help.aliyun.com/document_detail/2391512.html)。

## 快速集成
1. 根据前提条件，完成License的设置

2. 将AUIShortEpisode和[AUIFoundation](https://github.com/aliyunvideo/MONE_demo_opensource_iOS/tree/main/AUIBaseKits/AUIFoundation)拷贝到与工程的Podfile同一目录下

3. 修改工程的Podfile文件。根据自身业务需求进行集成：
   
```ruby
#需要iOS10.0及以上才能支持
platform :ios, '10.0'

target '你的App target' do
  # 根据自己的业务场景，集成合适的音视频终端SDK，支持：AliPlayerSDK_iOS、AliVCSDK_Premium、AliVCSDK_Standard、AliVCSDK_UGC等
  pod 'AliPlayerSDK_iOS'
  
  # 基础UI组件
  pod 'AUIFoundation/All', :path => "./AUIFoundation/"
  
  # 短剧UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
  pod 'AUIShortEpisode/AliPlayerSDK_iOS', :path => "./AUIShortEpisode/"
end
```

4. 执行pod install，成功后，可以在工程Pods中找到AUIShortEpisode和AUIFoundation目录
   

## 功能开发
1. 编写功能入口代码
   
在当前页面中打开短剧主界面AUIShortEpisodeViewController
```ObjC
#import "AUIShortEpisodeViewController.h"

AUIShortEpisodeViewController *vc = [[AUIShortEpisodeViewController alloc] init];
[self.navigationController pushViewController:vc animated:YES];
```

2. 加载数据集

本组件默认使用了内置的剧集数据进行演示，在你集成组件后需要修改这块的逻辑，需要对接到你的服务端，通过服务端提供的接口来获取剧集数据

- 在源码中找到AUIShortEpisodeDataManager类，进入fetchData:completed:方法，修改为服务端接口实现
```ObjC
//  AUIShortEpisodeData.m

@implementation AUIShortEpisodeDataManager

+ (void)fetchData:(NSString *)eid completed:(void (^)(AUIShortEpisodeData *, NSError *))completed {
    // TODO: 请求服务端返回短剧数据，需要你的服务端提供接口，并在这里请求接口
    // TODO：接口成功返回的数据还需转换为AUIShortEpisodeData，最终通过completed参数回调给业务
    
}

```

- 剧集模型字段说明

从服务端获取到的数据，需要根据数据协议转换为剧集模型

a. 剧集：AUIShortEpisodeData
  
| 字段 |  含义   |
|-----|--------|
| id |	剧集唯一ID |
| title |	剧集名称 |
| list |	剧集视频列表 |

b. 单集视频：AUIVideoInfo
  
| 字段 |  含义   |
|-----|--------|
| videoId |	视频唯一标识 |
| url |	播放源url |
| duration |	时长 |
| coverUrl |	封面 |
| author |	作者 |
| title |	标题 |
| videoPlayCount |	播放次数 |
| isLiked |	是否被点赞 |
| likeCount |	点赞数 |
| commentCount |	评论数 |
| shareCount |	分享数 |


3. 视频互动功能开发

点赞、评论、分享仅在视频上透出入口，点击后具体的操作需要自己来实现，可以到AUIShortEpisodeViewController类中对接
```ObjC
//  AUIShortEpisodeViewController.m

    cell.onLikeBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell, AVBaseButton *likeBtn) {
        likeBtn.selected = !likeBtn.selected;
        cell.videoInfo.isLiked = likeBtn.selected;
        cell.videoInfo.likeCount = likeBtn.selected ? (cell.videoInfo.likeCount + 1) : (cell.videoInfo.likeCount - 1);
        [cell refreshUI];
        // TODO: 发送点赞请求给服务端，需要自己实现
    };
    cell.onCommentBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell, AVBaseButton *commentBtn) {
        // TODO: 打开评论页面，需要自己实现
    };
    cell.onShareBtnClickBlock = ^(AUIShortEpisodePlayCell * _Nonnull cell, AVBaseButton *shareBtn) {
        // TODO: 打开分享页面，需要自己实现
    };

```

## 核心能力

本组件功能通过阿里云播放器SDK的AliListPlayer进行实现，使用了本地缓存、智能预加载、智能预渲染等核心能力，在播放延迟、播放稳定性方面大幅度提升观看体验。
具体介绍参考[进阶功能](https://help.aliyun.com/zh/vod/developer-reference/advanced-features-1)