Pod::Spec.new do |s|
  s.name             = 'QTEventBus'
  s.version          = '0.1.3'
  s.summary          = '优雅的处理全局事件'
  s.description      = <<-DESC
                       优雅的处理全局事件,类型安全，支持同步/异步发送，同步/异步监听
			DESC

  s.homepage         = 'https://github.com/LeoMobileDeveloper/QTEventBus'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Leo' => 'leomobiledeveloper@gmail.com' }
  s.source           = { :git => 'https://github.com/leomobiledeveloper/QTEventBus.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/Core/*.{h,m}'
  end

  s.subspec 'AppModule' do |app|
    app.source_files = 'Sources/UIApplication/*.{h,m}'
    app.framework = 'UIKit'
    app.dependency 'QTEventBus/Core'
  end
end
