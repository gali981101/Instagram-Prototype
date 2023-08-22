# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  end
 end
end

target 'Post-Prototype' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  pod 'Firebase', '10.13.0'
  pod 'FirebaseAnalytics', '10.13.0'
  pod 'FirebaseAuth', '10.13.0'
  pod 'FirebaseCore', '10.13.0'
  pod 'FirebaseFirestore', '10.13.0'
  pod 'FirebaseStorage', '10.13.0'
  pod 'IQKeyboardManagerSwift'
  pod 'SDWebImage', '~> 5.0'

  # Pods for Post-Prototype
  
end
