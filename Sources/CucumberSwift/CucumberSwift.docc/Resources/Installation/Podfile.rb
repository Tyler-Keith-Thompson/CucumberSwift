# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CucumberSwiftSample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CucumberSwiftSample

  target 'CucumberSwiftSampleTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CucumberSwiftSampleUITests' do
    # Pods for testing
    pod 'CucumberSwift' # <-- Add CucumberSwift to whatever testing target you'd like
  end

end
