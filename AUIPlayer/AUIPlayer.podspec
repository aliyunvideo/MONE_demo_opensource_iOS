#
# Be sure to run `pod lib lint AUIPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIPlayer'
  s.version          = '1.8.0'
  s.summary          = 'A short description of AUIPlayer.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS.git', :tag =>"v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.static_framework = true

  s.subspec 'VideoFlow' do |ss|
    ss.source_files = 'AUIVideoFlow/Class/**/*.{h,m,mm}'
    ss.resource = 'AUIVideoFlow/Resources/AUIVideoFlow.bundle'
    ss.dependency 'MJRefresh'
    ss.dependency 'MRDLNA'
    ss.dependency 'SDWebImage'
    ss.dependency 'Masonry'
    ss.dependency 'MBProgressHUD'
    ss.dependency 'FMDB'
    ss.dependency 'CocoaAsyncSocket'
    ss.dependency 'BarrageRenderer'
    ss.prefix_header_contents = '#import "AUIVideoFlow.h"'
  end

  s.subspec 'VideoList' do |ss|
    ss.source_files = 'AUIVideoList/Class/**/*.{h,m,mm}'
    ss.resource = 'AUIVideoList/Resources/AUIVideoList.bundle'
    ss.dependency 'SDWebImage'
    ss.prefix_header_contents = '#import "AUIVideoList.h"'
  end
  
#  s.subspec 'VideoCustom' do |ss|
#    ss.source_files = 'AUIVideoCustom/Class/**/*.{h,m,mm}'
#    ss.resource = 'AUIVideoCustom/Resources/**'
#    ss.dependency 'IQKeyboardManager'
#    ss.dependency 'AFNetworking'
#    ss.dependency 'FMDB'
#    ss.dependency 'JSONModel'
#    ss.dependency 'ZipArchive'
#    ss.dependency 'MBProgressHUD'
#    ss.dependency 'MJRefresh'
#    ss.prefix_header_contents = '#import "AUIVideoCustom.h"'
#  end
  
  s.subspec 'All' do |ss|
    ss.resource = 'Resources/AlivcPlayer.bundle'
    ss.source_files = 'Class/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'AUIPlayer/VideoFlow'
    ss.dependency 'AUIPlayer/VideoList'
    #ss.dependency 'AUIPlayer/VideoCustom'
    # ss.dependency 'UMCCommon','2.0.0'
    # ss.dependency 'UMCAnalytics','6.0.1'
    ss.prefix_header_contents = '#import "AlivcPlayerDemo.h"'
  end
  
  s.subspec 'AliVCSDK_Premium' do |ss|
    ss.dependency 'AliVCSDK_Premium'
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'AliVCSDK_Standard'
  end
  
  s.subspec 'AliVCSDK_BasicLive' do |ss|
    ss.dependency 'AliVCSDK_BasicLive'
  end
  
  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.dependency 'AliVCSDK_InteractiveLive'
  end
  
  s.subspec 'AliVCSDK_UGC' do |ss|
    ss.dependency 'AliVCSDK_UGC'
  end
  
  s.subspec 'AliVCSDK_UGCPro' do |ss|
    ss.dependency 'AliVCSDK_UGCPro'
  end
  
  s.subspec 'AliVCSDK_StandardLive' do |ss|
    ss.dependency 'AliVCSDK_StandardLive'
  end
  
  s.subspec 'AliVCSDK_PremiumLive' do |ss|
    ss.dependency 'AliVCSDK_PremiumLive'
  end
  
  s.subspec 'AliPlayerSDK_iOS' do |ss|
    ss.dependency 'AliPlayerSDK_iOS'
  end
  
  s.subspec 'AliPlayerPartSDK_iOS' do |ss|
    ss.dependency 'AliPlayerPartSDK_iOS'
    ss.dependency 'QuCore-ThirdParty'
  end
  
end
