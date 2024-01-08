简体中文 | [English](README.en.md)

# 阿里云MediaBox SDK Demo

## 代码结构
```
├── 根目录                                    
│   ├── AUIBaseKits                            // 依赖的AUI基础组件源码文件
│       ├── AUIBeauty                          // 依赖美颜组件
│       ├── AUIFoundation                      // 依赖基础UI组件
│   ├── AlivcLiveDemo                          // 直播模块源码文件
│   ├── AlivcPlayerDemo                        // 播放器模块源码文件
│   ├── AlivcRtcDemo                           // 互动直播模块源码文件
│   ├── AlivcUgsvDemo                          // 短视频生产模块源码文件
│   ├── AlivcAIODemo                           // 一体化聚合页模块源码文件
│   ├── AlivcAIODemo.xcodeproj                 // Demo的Project
│   ├── AlivcAIODemo.xcworkspace               // Demo的workspace
│   ├── Podfile                                // Demo的podfile文件
│   ├── Resources                              // 资源文件
│   ├── README.md                              // Readme
```


## 跑通demo

1. 源码下载后，进入根目录
2. 在根目录下执行“pod install  --repo-update”，自动安装依赖SDK
3. 打开工程文件“AlivcAIODemo.xcworkspace”，修改包Id
4. 在控制台上申请试用License，获取License文件和LicenseKey，如果已有直接进入下一步
5. 把License文件放到根目录下，并修改文件名为“license.crt”
6. 把“LicenseKey”（如果没有，请在控制台拷贝），打开“AlivcAIODemo/Info.plist”，填写到字段“AlivcLicenseKey”的值中
7. 编译运行
