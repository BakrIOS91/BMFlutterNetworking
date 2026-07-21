#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint bm_flutter_networking.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'bm_flutter_networking'
  s.version          = '0.1.12'
  s.summary          = 'A Flutter networking package providing a type-safe network layer with SSL pinning, token refresh, interceptors, and connectivity monitoring.'
  s.description      = <<-DESC
A Flutter networking package providing a type-safe network layer with SSL pinning, token refresh, interceptors, and connectivity monitoring.
                       DESC
  s.homepage         = 'https://github.com/BakrIOS91/BMFlutterNetworking'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Bakr Mohamed' => 'bakrios91@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
