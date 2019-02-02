Pod::Spec.new do |s|
  s.name             = 'YFMessageCenter'
  s.version          = '0.0.1'
  s.summary          = 'iOS 基于 Protocol 的消息派发组件'
  s.description      = <<-DESC
                       YFMessageCenter is a part of YFKit
                       DESC
  s.homepage         = 'https://github.com/laichanwai/YFMessageCenter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'laizw' => 'i@laizw.cn' }
  s.source           = { :git => 'https://github.com/laichanwai/YFMessageCenter.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'YFMessageCenter/**/*.{h,m}'
end
