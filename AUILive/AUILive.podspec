#
# Be sure to run `pod lib lint AUILive.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUILive'
  s.version          = '1.7.0'
  s.summary          = 'A short description of AUILive.'

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
  
  s.subspec 'LiveCommon' do |ss|
    ss.resource = 'AUILiveCommon/Resources/AUILiveCommon.bundle'
    ss.source_files = 'AUILiveCommon/Class/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'Masonry'
    ss.prefix_header_contents = '#import "AUILiveCommon.h"'
    ss.dependency 'AUILive/LiveIntelligentDenoise'
  end
  
  s.subspec 'LiveCameraPush' do |ss|
    ss.source_files = 'AUILiveCameraPush/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILiveCameraPush/Resources/*'
    ss.dependency 'AUILive/LiveCommon'
    ss.prefix_header_contents = '#import "AUILiveCameraPush.h"'
  end
  
  s.subspec 'LiveRecordPush' do |ss|
    ss.source_files = 'AUILiveRecordPush/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILiveRecordPush/Resources/AUILiveRecordPush.bundle'
    ss.dependency 'AUILive/LiveCommon'
    ss.prefix_header_contents = '#import "AUILiveRecordPush.h"'
  end
  
  s.subspec 'LivePlay' do |ss|
    ss.source_files = 'AUILivePlay/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILivePlay/Resources/AUILivePlay.bundle'
    ss.dependency 'AUILive/LiveCommon'
    ss.prefix_header_contents = '#import "AUILivePlay.h"'
  end
  
  s.subspec 'LiveRtsPlay' do |ss|
    ss.source_files = 'AUILiveRtsPlay/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILiveRtsPlay/Resources/AUILiveRtsPlay.bundle'
    ss.dependency 'AUILive/LiveCommon'
    ss.prefix_header_contents = '#import "AUILiveRtsPlay.h"'
  end
  
  s.subspec 'LiveLinkMic' do |ss|
    ss.source_files = 'AUILiveLinkMic/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILiveLinkMic/Resources/AUILiveLinkMic.bundle'
    ss.dependency 'AUILive/LiveCommon'
    ss.prefix_header_contents = '#import "AUILiveLinkMic.h"'
  end
  
  s.subspec 'LivePK' do |ss|
    ss.source_files = 'AUILivePK/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILivePK/Resources/AUILivePK.bundle'
    ss.dependency 'AUILive/LiveCommon'
    ss.prefix_header_contents = '#import "AUILivePK.h"'
  end
  
  s.subspec 'LiveIntelligentDenoise' do |ss|
    ss.vendored_frameworks = 'AUILiveIntelligentDenoise/MNN.framework', 'AUILiveIntelligentDenoise/pluginAliDenoise.framework'
  end

  s.subspec 'List' do |ss|
    ss.resource = 'Resources/AlivcLive.bundle'
    ss.source_files = 'Class/**/*.{h,m,mm}'
    ss.prefix_header_contents = '#import "AlivcLiveDemo.h"'
  end

  s.subspec 'All' do |ss|
    ss.dependency 'AUILive/List'
    ss.dependency 'AUILive/LiveCameraPush'
    ss.dependency 'AUILive/LiveRecordPush'
    ss.dependency 'AUILive/LivePlay'
    ss.dependency 'AUILive/LiveRtsPlay'
    ss.dependency 'AUILive/LiveLinkMic'
    ss.dependency 'AUILive/LivePK'
  end
  
  s.subspec 'AliVCSDK_Premium' do |ss|
    ss.dependency 'AliVCSDK_Premium'
    ss.dependency 'AUIQueenCom/AliVCSDK_Premium'
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'AliVCSDK_Standard'
    ss.dependency 'AUIQueenCom/Queen'
  end
  
  s.subspec 'AliVCSDK_BasicLive' do |ss|
    ss.dependency 'AliVCSDK_BasicLive'
    ss.dependency 'AUIQueenCom/Queen'
  end
  
  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.dependency 'AliVCSDK_InteractiveLive'
    ss.dependency 'AUIQueenCom/Queen'
  end
  
  s.subspec 'AliVCSDK_StandardLive' do |ss|
    ss.dependency 'AliVCSDK_StandardLive'
    ss.dependency 'AUIQueenCom/AliVCSDK_StandardLive'
  end
  
  s.subspec 'AliVCSDK_PremiumLive' do |ss|
    ss.dependency 'AliVCSDK_PremiumLive'
    ss.dependency 'AUIQueenCom/AliVCSDK_PremiumLive'
  end
  
  s.subspec 'AlivcLivePusher' do |ss|
    ss.dependency 'AlivcLivePusher'
    ss.dependency 'AUIQueenCom/Queen'
  end

end
