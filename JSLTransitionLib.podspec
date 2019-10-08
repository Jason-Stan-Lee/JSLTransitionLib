#
# Be sure to run `pod lib lint JSLTransitionLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JSLTransitionLib'
  s.version          = '2.0.1'
  s.summary          = 'Help you to hold custom view transitions EASYLY !'
  s.swift_version = '4.2'
  s.platform = 'ios'
  s.ios.deployment_target = '9.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '该库集成了转场手势管理、转场代理以及交互转场进度控制，使接入方更关注动画细节，不关心转场相关的基础开发。可以使不了解自定义转场内部细节的开发人员也能迅速上手'

  s.homepage         = 'https://github.com/Jason-Stan-Lee/JSLTransitionLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jason_lee_92@yahoo.com' => 'Jason-Stan-Lee' }
  s.source           = { :git => 'https://github.com/Jason-Stan-Lee/JSLTransitionLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'JSLTransitionLib/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JSLTransitionLib' => ['JSLTransitionLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
