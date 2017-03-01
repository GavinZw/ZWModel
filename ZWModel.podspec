#
#  Be sure to run `pod spec lint ZWModel.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
spec.name         = 'ZWModel'
spec.summary      = 'High performance model framework for iOS/OSX. The YYmodel renamed.'
spec.version      = '0.0.1'
spec.license      =  { :type => 'MIT', :file => 'LICENSE' }
spec.authors      = { 'gavin' => 'lovegavin@outlook.com' }
spec.homepage     = 'https://github.com/GavinZw/ZWModel'

spec.ios.deployment_target = '8.0'
spec.ios.deployment_target.osx.deployment_target = '10.7'
spec.watchos.deployment_target = '2.0'
spec.tvos.deployment_target = '9.0'

spec.source       = { :git => 'https://github.com/GavinZw/ZWModel.git', :tag => spec.version.to_s }

spec.requires_arc          = true
spec.source_files = 'ZWModel/*.{h,m}'
spec.public_header_files = 'ZWModel/*.{h}'

spec.frameworks = 'Foundation'

end
