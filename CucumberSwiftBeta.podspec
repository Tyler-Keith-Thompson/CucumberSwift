Pod::Spec.new do |s|
    s.name             = 'CucumberSwiftBeta'
    s.version          = '0.0.6'
    s.summary          = 'Beta for CucumberSwift.'

    s.description      = <<-DESC
  This repo is for those brave souls who want to try out new possibly very unstable features and give some feedback on them.
                         DESC
  
    s.homepage         = 'https://github.com/Tyler-Keith-Thompson/CucumberSwiftBeta'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Tyler Thompson' => 'Tyler.Thompson@Asynchrony.com' }
    s.source           = { :git => 'https://github.com/Tyler-Keith-Thompson/CucumberSwiftBeta.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '10.0'
    s.swift_version = '4.0'
  
    s.source_files = 'CucumberSwift/**/*.{swift,h,m}'
    s.resources = ["CucumberSwift/**/*.{json}"]  

    s.weak_framework = "XCTest"
    s.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
    }
end
  