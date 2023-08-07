#
# Be sure to run `pod lib lint AUIUgsv.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIUgsv'
  s.version          = '6.3.0'
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

  s.dependency 'VODUpload'
  s.dependency 'Masonry'
  s.dependency 'AFNetworking'
  s.dependency 'SDWebImage'
  s.dependency 'ZipArchive', '~> 1.4.0'

  s.subspec 'All' do |ss|
    ss.resource = 'Resources/*.bundle'
    ss.source_files = 'Class/**/*.{h,m,mm}'
    ss.vendored_frameworks = 'framework/*.framework'
    ss.dependency 'AUIFoundation/All'
  end
  
  s.subspec 'List' do |ss|
    ss.resource = 'Resources/AlivcUgsv.bundle'
    ss.source_files = 'Class/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
  end

  s.subspec 'Recorder' do |ss|
    ss.resource = 'Resources/AlivcUgsv.bundle','Resources/FaceSticker.bundle','Resources/Music.bundle','Resources/Filter.bundle'
    ss.source_files = 'Class/Base/**/*.{h,m,mm}', 'Class/Components/**/*.{h,m,mm}', 'Class/Modules/VideoRecorder/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
  end

  s.subspec 'Editor' do |ss|
    ss.resource = 'Resources/*.bundle'
    ss.source_files = 'Class/Base/**/*.{h,m,mm}', 'Class/Components/**/*.{h,m,mm}', 'Class/Modules/VideoEditor/**/*.{h,m,mm}'
    ss.vendored_frameworks = 'framework/*.framework'
    ss.dependency 'AUIFoundation/All'
  end 

  s.subspec 'Clipper' do |ss|
    ss.resource = 'Resources/AlivcUgsv.bundle'
    ss.source_files = 'Class/Base/**/*.{h,m,mm}', 'Class/Components/**/*.{h,m,mm}', 'Class/Modules/VideoCrop/**/*.{h,m,mm}'
    ss.vendored_frameworks = 'framework/*.framework'
    ss.dependency 'AUIFoundation/All'
  end
  
  s.subspec 'Template' do |ss|
    ss.resource = 'Resources/AlivcUgsv.bundle','Resources/Template.bundle','Resources/Music.bundle'
    ss.source_files = 'Class/Base/**/*.{h,m,mm}', 'Class/Components/**/*.{h,m,mm}', 'Class/Modules/VideoTemplate/**/*.{h,m,mm}'
    ss.vendored_frameworks = 'framework/*.framework'
    ss.dependency 'AUIFoundation/All'
  end
  
  s.subspec 'AliVCSDK_Premium' do |ss|
    ss.dependency 'AliVCSDK_Premium'
    ss.dependency 'AUIQueenCom/AliVCSDK_Premium'
  end
  
  s.subspec 'AliVCSDK_Premium_all' do |ss|
    ss.dependency 'AUIUgsv/AliVCSDK_Premium'
    ss.dependency 'AliVCSDK_Premium/AlivcUgsvTemplate'
    ss.dependency 'AliVCSDK_Premium/AlivcUgsvBundle'
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'AliVCSDK_Standard'
    ss.dependency 'AUIQueenCom/Queen'
  end
  
  s.subspec 'AliVCSDK_Standard_all' do |ss|
    ss.dependency 'AUIUgsv/AliVCSDK_Standard'
    ss.dependency 'AliVCSDK_Standard/AlivcUgsvTemplate'
    ss.dependency 'AliVCSDK_Standard/AlivcUgsvBundle'
  end
  
  s.subspec 'AliVCSDK_UGC' do |ss|
    ss.dependency 'AliVCSDK_UGC'
    ss.dependency 'AUIQueenCom/Queen'
  end
  
  s.subspec 'AliVCSDK_UGC_all' do |ss|
    ss.dependency 'AUIUgsv/AliVCSDK_UGC'
    ss.dependency 'AliVCSDK_UGC/AlivcUgsvTemplate'
    ss.dependency 'AliVCSDK_UGC/AlivcUgsvBundle'
  end
  
  s.subspec 'AliVCSDK_UGCPro' do |ss|
    ss.dependency 'AliVCSDK_UGCPro'
    ss.dependency 'AUIQueenCom/AliVCSDK_UGCPro'
  end
  
  s.subspec 'AliVCSDK_UGCPro_all' do |ss|
    ss.dependency 'AUIUgsv/AliVCSDK_UGCPro'
    ss.dependency 'AliVCSDK_UGCPro/AlivcUgsvTemplate'
    ss.dependency 'AliVCSDK_UGCPro/AlivcUgsvBundle'
  end
  
  
  s.subspec 'AliyunVideoSDKPro' do |ss|
    ss.dependency 'AliyunVideoSDKPro'
    ss.dependency 'AUIQueenCom/Queen'
  end
  
  s.subspec 'AliyunVideoSDKPro_all' do |ss|
    ss.dependency 'AliyunVideoSDKPro/all'
    ss.dependency 'AUIQueenCom/Queen'
  end

  s.subspec 'AliyunVideoSDKBasic' do |ss|
    ss.dependency 'AliyunVideoSDKBasic'
  end
  
end
