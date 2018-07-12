Pod::Spec.new do |s|
  s.name             = 'QTEventBus'
  s.version          = '0.1.0'
  s.summary          = '优雅的处理全局事件'
  s.description      = <<-DESC
                       优雅的处理全局事件,类型安全，支持同步/异步发送，同步/异步监听
			DESC

  s.homepage         = 'https://github.com/LeoMobileDeveloper/QTEventBus'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Leo' => 'leomobiledeveloper@gmail.com' }
  s.source           = { :git => 'https://github.com/leomobiledeveloper/QTEventBus.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Sources/**/*'
end
