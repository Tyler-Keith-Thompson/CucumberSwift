Pod::Spec.new do |s|
    s.name             = 'CucumberSwift'
    s.version          = '1.0.15'
    s.summary          = 'A lightweight swift only cucumber implementation.'

    s.description      = <<-DESC
  This is a swift only cucumber implementation. This particular implementation contains feature, scenario and step level hooks that Cucumberish does not and has the added benefit of not requiring an objective-c bridging header 
                         DESC
  
    s.homepage         = 'https://gitlab.asynchrony.com/tyler.thompson/CucumberSwift'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Tyler Thompson' => 'Tyler.Thompson@Asynchrony.com' }
    s.source           = { :git => 'https://gitlab.asynchrony.com/tyler.thompson/CucumberSwift.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '10.0'
    s.swift_version = '4.0'
  
    s.source_files = 'CucumberSwift/**/*.{swift,h,m}'
    s.resources = ["CucumberSwift/**/*.{storyboard,xib,xcassets,otf,ttf}"]  

    s.weak_framework = "XCTest"
    s.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
    }
end
  