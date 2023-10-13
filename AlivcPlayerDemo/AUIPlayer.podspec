#
# Be sure to run `pod lib lint AUIPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIPlayer'
  s.version          = '6.5.0'
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
  
  s.subspec 'PlayerList' do |ss|
    ss.resource = 'AUIPlayerList/Resources/AlivcPlayer.bundle'
    ss.source_files = 'AUIPlayerList/Class/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.prefix_header_contents = '#import "AlivcPlayerDemo.h"'
  end

  s.subspec 'VideoFlow' do |ss|
    ss.source_files = 'AUIVideoFlow/Class/**/*.{h,m,mm}'
    ss.resource = 'AUIVideoFlow/Resources/AUIVideoFlow.bundle'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'MJRefresh'
    ss.dependency 'SDWebImage'
    ss.dependency 'Masonry'
    ss.dependency 'MBProgressHUD'
    ss.dependency 'FMDB'
    ss.prefix_header_contents = '#import "AUIVideoFlow.h"'
  end
  
  s.subspec 'VideoList' do |ss|
    ss.resource = 'AUIVideoList/AUIVideoListCommon/Resources/AUIVideoList.bundle'
    ss.source_files = 'AUIVideoList/AUIVideoListCommon/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'SDWebImage'
    ss.dependency 'AFNetworking'
    ss.prefix_header_contents = '#import "AUIVideoList.h"'
    
    ss.subspec "FunctionList" do |sss|
      sss.source_files = 'AUIVideoList/AUIVideoFunctionList/AUIVideoFunctionListView.h',
                         'AUIVideoList/AUIVideoFunctionList/AUIVideoFunctionListView.m',
                         'AUIVideoList/AUIVideoFunctionList/Views/*.{h,m,mm}'
    end
    
    ss.subspec "StandradList" do |sss|
      sss.source_files = 'AUIVideoList/AUIVideoStandradList/AUIVideoStandradListView.h',
                         'AUIVideoList/AUIVideoStandradList/AUIVideoStandradListView.m',
                         'AUIVideoList/AUIVideoStandradList/Views*/*.{h,m,mm}'
    end
    ss.subspec "ShortEpisode" do |sss|
      sss.source_files = 'AUIVideoList/AUIShortEpisode/**/*.{h,m,mm}'
      sss.resource = 'AUIVideoList/AUIShortEpisode/Resources/AUIShortEpisode.bundle'
    end
  end
        
  s.subspec 'All' do |ss|
    ss.dependency 'AUIPlayer/PlayerList'
    ss.dependency 'AUIPlayer/VideoFlow'
    ss.dependency 'AUIPlayer/VideoList'
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
