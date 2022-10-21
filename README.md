# 跑通阿里云音视频终端SDK示例代码

## 集成源码
* clone源码
```sh
git clone git@github.com:aliyunvideo/MONE_demo_opensource_iOS.git
```
* demo通过cocoapods进行自动集成，如果没有安装cocoapods，请先安装，安装后在AlivcAIODemo目录下执行pod install
```sh
cd AlivcAIODemo
# 如果失败，请带上“--reop-update”参数
pod install
```
* 打开工程
```sh
open AlivcAIODemo.xcworkspace
```

## 配置License
* 如果还没有License，请先[申请试用License](https://help.aliyun.com/document_detail/438207.html)，把License文件下载到本地，并分别记下申请时填写的“Bundle Id”和控制台颁给的“LicenseKey”
* 下载后的License文件修改文件名为“license.crt”，并拷贝到“AlivcAIODemo/”目录下
* 打开工程，修改BundleId为申请License时填写的“Bundle Id”
* 打开“AlivcAIODemo/Info.plist”，修改AlivcLicenseKey为控制台颁给的“LicenseKey”

## 编译运行
在配置好License后，直接编译运行即可
