#
# Be sure to run `pod lib lint AUIUgsv.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIUgsv'
  s.version          = '6.7.0'
  s.summary          = 'A short description of AUIUgsv.'

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
  s.default_subspec = 'Common'
  
  s.dependency 'Masonry'
  s.dependency 'AFNetworking'
  s.dependency 'SDWebImage'
  s.dependency 'ZipArchive'

  s.subspec 'All' do |ss|
    ss.source_files = 'Class/List/**/*.{h,m,mm}'
    ss.dependency 'AUIUgsv/Recorder'
    ss.dependency 'AUIUgsv/Editor'
    ss.dependency 'AUIUgsv/Clipper'
    ss.dependency 'AUIUgsv/Template'
  end
  
  s.subspec 'Basic' do |ss|
    ss.source_files = 'Class/List/**/*.{h,m,mm}'
    ss.dependency 'AUIUgsv/Recorder_NoBeauty'
    ss.dependency 'AUIUgsv/Clipper'
  end
  
  s.subspec 'Common' do |ss|
    ss.resource = 'Resources/AlivcUgsv.bundle'
    ss.source_files = 'Class/Base/**/*.{h,m,mm}', 'Class/Components/**/*.{h,m,mm}'
    ss.vendored_frameworks = 'framework/*.framework'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'VODUpload'
  end

  s.subspec 'Recorder' do |ss|
    ss.dependency 'AUIUgsv/Recorder_NoBeauty'
    ss.dependency 'AUIBeauty/Common'
    ss.pod_target_xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 ENABLE_BEAUTY'}
  end
  
  s.subspec 'Recorder_NoBeauty' do |ss|
    ss.dependency 'AUIUgsv/Common'
    ss.resource = 'Resources/FaceSticker.bundle','Resources/Music.bundle','Resources/Filter.bundle','Resources/AnimationEffects.bundle'
    ss.source_files = 'Class/Modules/VideoRecorder/**/*.{h,m,mm}'
  end

  s.subspec 'Editor' do |ss|
    ss.dependency 'AUIUgsv/Common'
    ss.resource = 'Resources/AnimationEffects.bundle', 'Resources/AnimationFrag.bundle', 'Resources/CaptionBub.bundle', 'Resources/CaptionFont.bundle', 'Resources/CaptionStyle.bundle', 'Resources/Filter.bundle', 'Resources/FlowerFont.bundle', 'Resources/Music.bundle', 'Resources/Sticker.bundle'
    ss.source_files = 'Class/Modules/VideoEditor/**/*.{h,m,mm}'
  end

  s.subspec 'Clipper' do |ss|
    ss.dependency 'AUIUgsv/Common'
    ss.source_files = 'Class/Modules/VideoCrop/**/*.{h,m,mm}'
  end
  
  s.subspec 'Template' do |ss|
    ss.dependency 'AUIUgsv/Common'
    ss.dependency 'AUIUgsv/Clipper'
    ss.resource = 'Resources/Template.bundle','Resources/Music.bundle'
    ss.source_files = 'Class/Modules/VideoTemplate/**/*.{h,m,mm}'
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'AliVCSDK_Standard'
  end
  
  s.subspec 'AliVCSDK_Standard_all' do |ss|
    ss.dependency 'AUIUgsv/AliVCSDK_Standard'
    ss.dependency 'AliVCSDK_Standard/AlivcUgsvTemplate'
    ss.dependency 'AliVCSDK_Standard/AlivcUgsvBundle'
  end
  
  s.subspec 'AliVCSDK_UGC' do |ss|
    ss.dependency 'AliVCSDK_UGC'
  end
  
  s.subspec 'AliVCSDK_UGC_all' do |ss|
    ss.dependency 'AUIUgsv/AliVCSDK_UGC'
    ss.dependency 'AliVCSDK_UGC/AlivcUgsvTemplate'
    ss.dependency 'AliVCSDK_UGC/AlivcUgsvBundle'
  end
  
  
  s.subspec 'AliyunVideoSDKPro' do |ss|
    ss.dependency 'AliyunVideoSDKPro'
  end
  
  s.subspec 'AliyunVideoSDKPro_all' do |ss|
    ss.dependency 'AliyunVideoSDKPro/all'
  end

  s.subspec 'AliyunVideoSDKBasic' do |ss|
    ss.dependency 'AliyunVideoSDKBasic'
  end
  
end
