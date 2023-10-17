# AUIVideoList组件

## 代码结构
```
├── AUIVideoList  // Demo根目录
│   ├── AUIVideoListCommon                // 公共组件代码
│   ├── AUIVideoFunctionList              // 沉浸式短视频性能组件代码
│   ├── AUIVideoStandradList              // 沉浸式短视频标准组件代码
│   ├── AUIVideoList.podspec              // 本地pod文件
│   ├── README.md   // Readme   

```

## 集成组件到工程
1. 确保已经申请播放器SDK的License。把License文件放到工程目录下，并修改文件名为“license.crt”。打开“Info.plist”，把“LicenseKey”，填写到字段“AlivcLicenseKey”的值中；把“license.crt”相当于mainBundle的路径填写到字段“AlivcLicenseFile”的值中

2. 集成准备：将AUIVideoList的所有文件拷贝到与Podfile同一目录下

3. 修改工程的Podfile文件。根据自身业务需求进行集成：
- 集成沉浸式短视频性能组件
   pod "AUIVideoList/FunctionList", :path => "AUIVideoList/"
   
- 集成沉浸式短视频标准组件
   pod "AUIVideoList/StandradList", :path => "AUIVideoList/"
   
>注意：需要同时集成AUIFoundation这个公共UI组件库。

4. 执行pod install，成功后，可以在工程Pods中找到AUIVideoList目录
   
5. 编写功能入口代码
- 集成了沉浸式短视频性能组件
```ObjC
#import "AUIVideoFunctionListView.h"

AUIVideoFunctionListView *vc = [[AUIVideoFunctionListView alloc] init];
[vc loadSources:xxxx]; // xxxx 代表列表数据源，具体可参考接口
[self.navigationController pushViewController:vc animated:YES];
```

-  集成了沉浸式短视频标准组件
```ObjC
#import "AUIVideoStandradListView.h"

AUIVideoStandradListView *vc = [[AUIVideoStandradListView alloc] init];
[vc loadSources:xxxx]; // xxxx 代表列表数据源，具体可参考接口
[self.navigationController pushViewController:vc animated:YES];
```

