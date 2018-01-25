source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'LoyaltyCard(Simple)' do
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'Firebase/RemoteConfig'
    pod 'FBSDKLoginKit'
    pod 'GoogleSignIn'
    pod 'FBSDKCoreKit'
    pod 'Fabric'
    pod 'TwitterKit'
    pod 'QRCodeReader.swift'
    pod 'Device.swift'
    pod 'ObjectMapper'
    pod 'Kingfisher'
    pod 'IQKeyboardManagerSwift'
    pod 'KYDrawerController'
    pod 'BEMCheckBox'
    pod 'DatePickerDialog'
    pod 'DZNEmptyDataSet'
    pod 'RadioButton'
    pod 'Alamofire', '~> 4.3'
    pod 'SwiftyJSON'
    pod 'Firebase/DynamicLinks'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
