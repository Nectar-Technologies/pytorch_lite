#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pytorch_lite.podspec' to validate before publishing.
#

Pod::Spec.new do |s|
  s.name             = 'pytorch_lite'
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
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # s.ios.deployment_target = '12.0'
  # s.public_header_files = 'Classes/**/*.h'
  # Flutter.framework does not contain a i386 slice.

  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/LibTorch/install/include"',
    'LIBRARY_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/LibTorch/install/lib" "${PODS_ROOT}/LibTorchvision/install/lib"',
    'OTHER_LDFLAGS' => '-all_load -force_load $(PODS_ROOT)/LibTorch/install/lib/libtorch.a -force_load $(PODS_ROOT)/LibTorchvision/install/lib/libtorchvision.a'
  }

  s.static_framework = true
  s.dependency 'LibTorch', '~> 2.1.0'
  # s.dependency 'LibTorch-Lite', '~> 1.13.0.1'
  s.dependency 'LibTorchvision', '~> 0.14.0'
  s.swift_version = '5.0'

end