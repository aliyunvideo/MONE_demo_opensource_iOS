#
# Be sure to run `pod lib lint AUIShortEpisode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIShortEpisode'
  s.version          = '1.0.0'
  s.summary          = 'A short description of AUIShortEpisode.'

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
  
  s.default_subspec = 'AliVCSDK_Premium'
  
  s.subspec 'src' do |ss|
    ss.source_files = 'Source/**/*.{h,m,mm}'
    ss.resource = 'Resources/AUIShortEpisode.bundle'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'AFNetworking'
    ss.dependency 'SDWebImage'
  end
  
  s.subspec 'AliPlayerSDK_iOS' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliPlayerSDK_iOS'
  end
  
  s.subspec 'AliVCSDK_Premium' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_Premium'
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_Standard'
  end
  
  s.subspec 'AliVCSDK_BasicLive' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_BasicLive'
  end
  
  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_InteractiveLive'
  end
  
  s.subspec 'AliVCSDK_UGC' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_UGC'
  end
  
  s.subspec 'AliVCSDK_UGCPro' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_UGCPro'
  end
  
  s.subspec 'AliVCSDK_StandardLive' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_StandardLive'
  end
  
  s.subspec 'AliVCSDK_PremiumLive' do |ss|
    ss.dependency 'AUIShortEpisode/src'
    ss.dependency 'AliVCSDK_PremiumLive'
  end
  

  
end
