#
# Be sure to run `pod lib lint AlivcLiveDemo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUILiveCommon'
  s.version          = '6.3.0'
  s.summary          = 'A short description of AUILiveCommon.'

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

  s.subspec 'All' do |ss|
    ss.resource = 'Resources/AUILiveCommon.bundle'
    ss.source_files = 'Class/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'Masonry'
    ss.prefix_header_contents = '#import "AUILiveCommon.h"'
  end
  
  s.subspec 'AliVCSDK_Premium' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AliVCSDK_Premium'
    end
    
    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AliVCSDK_Premium/Basic'
      sss.dependency 'AUIBeauty/AliVCSDK_Premium'
    end
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AliVCSDK_Standard'
    end
    
    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AliVCSDK_Standard/Basic'
      sss.dependency 'AUIBeauty/Queen'
    end
  end
  
  s.subspec 'AliVCSDK_BasicLive' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AliVCSDK_BasicLive'
    end
    
    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AliVCSDK_BasicLive/Basic'
      sss.dependency 'AUIBeauty/Queen'
    end
  end
  
  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AliVCSDK_InteractiveLive'
    end

    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AliVCSDK_InteractiveLive/Basic'
      sss.dependency 'AUIBeauty/Queen'
    end
  end
  
  s.subspec 'AliVCSDK_StandardLive' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AliVCSDK_StandardLive'
    end
    
    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AliVCSDK_StandardLive/Basic'
      sss.dependency 'AUIBeauty/AliVCSDK_StandardLive'
    end
  end
  
  s.subspec 'AliVCSDK_PremiumLive' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AliVCSDK_PremiumLive'
    end
    
    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AliVCSDK_PremiumLive/Basic'
      sss.dependency 'AUIBeauty/AliVCSDK_PremiumLive'
    end
  end
    
  s.subspec 'AlivcLivePusher' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AlivcLivePusher'
    end
    
    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AlivcLivePusher/Basic'
      sss.dependency 'AUIBeauty/Queen'
    end
  end
  
  s.subspec 'AlivcLivePusher_Interactive' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AlivcLivePusher_Interactive'
    end
    
    ss.subspec 'Queen' do |sss|
      sss.dependency 'AUILiveCommon/AlivcLivePusher_Interactive/Basic'
      sss.dependency 'AUIBeauty/Queen'
    end
  end
  
  s.subspec 'AliPlayerSDK_iOS' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AliPlayerSDK_iOS'
    end
    
    ss.subspec 'Rts' do |sss|
      sss.dependency 'AUILiveCommon/AliPlayerSDK_iOS/Basic'
      sss.dependency 'AliPlayerSDK_iOS_ARTC'
      sss.dependency 'RtsSDK'
    end
  end
  
  s.subspec 'LiveLocalSDK' do |ss|
    ss.subspec 'Basic' do |sss|
      sss.dependency 'AUILiveLocalSDK/AlivcLivePusher_Basic'
    end
    
    ss.subspec 'Interactive' do |sss|
      sss.dependency 'AUILiveLocalSDK/AlivcLivePusher_Interactive'
      sss.dependency 'AUIBeauty/Queen'
    end
    
    ss.subspec 'IntelligentDenoise' do |sss|
      sss.dependency 'AUILiveLocalSDK/IntelligentDenoise'
    end
  end
end
