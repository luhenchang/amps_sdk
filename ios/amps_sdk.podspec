#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint amps_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'amps_sdk'
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
  s.dependency 'AMPSAdSDK'
  s.dependency 'AMPSASNPAdapter', '~> 5.1.5200.1'
  s.dependency 'AMPSBZAdapter', '5.1.49070.0'
  s.dependency 'AMPSGDTAdapter', '~> 5.1.41560.2'
  s.dependency 'AMPSKSAdapter', '~> 5.1.4920.0'
  s.dependency 'YYWebImage'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'amps_sdk_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
