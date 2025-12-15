#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rbm_qr_sdk_v1.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rbm_qr_sdk_v1'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Add the XCFramework
  s.vendored_frameworks = 'SdkQrCore.xcframework'
  
  # Configure framework search paths and module map
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  
  s.user_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/../.symlinks/plugins/rbm_qr_sdk_v1/ios',
    'OTHER_LDFLAGS' => '$(inherited) -framework SdkQrCore'
  }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'rbm_qr_sdk_v1_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
