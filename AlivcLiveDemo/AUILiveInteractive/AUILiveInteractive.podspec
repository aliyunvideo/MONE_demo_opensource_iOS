#
# Be sure to run `pod lib lint AUILiveInteractive.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUILiveInteractive'
  s.version          = '6.3.0'
  s.summary          = 'A short description of AUILiveInteractive.'

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

  s.ios.deployment_target = '8.0'
  s.static_framework = true

  s.subspec 'InteractiveCommon' do |ss|
    ss.source_files = 'AUILiveInteractiveCommon/**/*.{h,m,mm}'
  end

  s.subspec 'LinkMic' do |ss|
    ss.source_files = 'AUILiveLinkMic/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILiveLinkMic/Resources/AUILiveLinkMic.bundle'
    ss.dependency 'AUILiveCommon/All'
    ss.dependency 'AUILiveInteractive/InteractiveCommon'
    ss.dependency 'AUIFoundation/All'
    ss.prefix_header_contents = '#import "AUILiveLinkMic.h"'
  end
  
  s.subspec 'PK' do |ss|
    ss.source_files = 'AUILivePK/Class/**/*.{h,m,mm}'
    ss.resource = 'AUILivePK/Resources/AUILivePK.bundle'
    ss.dependency 'AUILiveCommon/All'
    ss.dependency 'AUILiveInteractive/InteractiveCommon'
    ss.dependency 'AUIFoundation/All'
    ss.prefix_header_contents = '#import "AUILivePK.h"'
  end
end
