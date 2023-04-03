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
2. 集成准备：将AUIVideoList的所有文件拷贝到工程指定的路径下
3. 修改工程的Podfile文件。分以下三种集成情况：
3.1. 只集成沉浸式短视频性能组件
   pod "AUIVideoList/FunctionList", :path => "xxxx/AUIVideoList/" (xxxx是指工程指定的路径)
3.2. 只集成沉浸式短视频标准组件
   pod "AUIVideoList/StandradList", :path => "xxxx/AUIVideoList/" (xxxx是指工程指定的路径)
3.3. 集成沉浸式短视频性能和标准组件
   pod "AUIVideoList/All", :path => "xxxx/AUIVideoList/" (xxxx是指工程指定的路径)
注意：需要同时集成AUIFoundation这个公共UI组件库。
4. 执行pod install，编译运行
5. 编译运行成功后，可以在工程Pods中找到AUIVideoList目录，其下有步骤3选择集成的对应目录
6. 编写功能入口代码。分以下两种情况：
6.1 集成了沉浸式短视频性能组件，直接调用AUIVideoFunctionListView.h
AUIVideoFunctionListView *vc = [[AUIVideoFunctionListView alloc] init];
[vc loadSources:xxxx]; // xxxx 代表列表数据源，具体可参考接口
[self.navigationController pushViewController:vc animated:YES];
6.2 集成了沉浸式短视频标准组件，直接调用AUIVideoStandradListView.h
AUIVideoStandradListView *vc = [[AUIVideoStandradListView alloc] init];
[vc loadSources:xxxx]; // xxxx 代表列表数据源，具体可参考接口
[self.navigationController pushViewController:vc animated:YES];
7. 建议使用AUIFoundation中的AVNavigationController管理导航栏进行沉浸式短视频组件页面跳转

