#use_frameworks!
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'


# ===================================集成音视频终端SDK===================================
def aliyun_demo_dependency_sdk
  pod 'AliVCSDK_Premium', '6.5.0'
end

# ===================================集成AUIFoundation===================================
def aliyun_demo_dependency_foundation
  pod 'AUIFoundation/All', :path => './AUIBaseKits/AUIFoundation/'
end

# ===================================Queen美颜集成===================================
def aliyun_demo_dependency_queen
  pod 'AUIBeauty/AliVCSDK_Premium',  :path => './AUIBaseKits/AUIBeauty/'
end

# ===================================直播推流集成===================================
def aliyun_demo_aui_live
  pod 'AUILive/AliVCSDK_Premium', :path => './AlivcLiveDemo/'
  pod 'AUILive/All', :path => './AlivcLiveDemo/'
end

# ===================================播放器集成===================================
def aliyun_demo_aui_player
  pod 'AUIPlayer/AliVCSDK_Premium', :path => './AlivcPlayerDemo/'
  pod 'AUIPlayer/All', :path => './AlivcPlayerDemo/'
end

# ===================================互动直播集成===================================
def aliyun_demo_aui_rtc
  pod 'AUIRtc/AliVCSDK_Premium', :path => './AlivcRtcDemo/'
  pod 'AUIRtc/All', :path => './AlivcRtcDemo/'
end

# ===================================短视频剪辑集成===================================
def aliyun_demo_aui_ugsv
  pod 'AUIUgsv/AliVCSDK_Premium_all', :path => './AlivcUgsvDemo/'
  pod 'AUIUgsv/All', :path => './AlivcUgsvDemo/'
end


target 'AlivcAIODemo' do
  pod 'WPKMobi', '~> 1.3.6.5' #itrace崩溃接入
  
  aliyun_demo_dependency_sdk
  aliyun_demo_dependency_queen
  aliyun_demo_dependency_foundation

  aliyun_demo_aui_ugsv
  aliyun_demo_aui_player
  aliyun_demo_aui_live
  aliyun_demo_aui_rtc
  
end


post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
end