#
# Binary pod for the static XCFrameworks produced by Scripts/build_xcframeworks.sh.
# TensorFlowLite (Swift wrapper, Apache-2.0) ships as its own static XCFramework;
# TensorFlowLiteC stays a dependency of the host. It is not vendored.
#
Pod::Spec.new do |s|
  s.name             = 'IMPetAudioSDK'
  s.version          = '0.1.2'
  s.summary          = 'INMO X pet sound recognition SDK, offline YAMNet (static XCFramework)'
  s.description      = <<-DESC
  INMO X 宠物声音识别 / 猫狗叫声语义翻译 SDK 静态二进制：纯离线，内置 YAMNet（tflite）做猫狗叫声检测，
  输出叫声语义、声学特征与风格提示。自带 TensorFlowLite.xcframework（TFLite 2.17.0 Swift 接口），
  依赖 TensorFlowLiteC 2.17.0。不能与官方 TensorFlowLiteSwift pod 同时使用。
                       DESC

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jiangqi' => 'jiangqi@inmo.com' }
  s.homepage         = 'https://github.com/INMO-X/IMPetAudioSDK'
  s.source           = { :git => 'https://github.com/INMO-X/IMPetAudioSDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
  s.static_framework = true

  s.vendored_frameworks = [
    'XCFrameworks/IMPetAudioSDK.xcframework',
    'XCFrameworks/Frameworks/TensorFlowLite.xcframework'
  ]

  s.frameworks = 'Foundation', 'Accelerate'

  # IMPetAudioSDKResources 与 SDK 内查找名绑定，不能改名。
  s.resource_bundles = {
    'IMPetAudioSDKResources' => [
      'Resources/yamnet.tflite',
      'Resources/yamnet_label_list.txt',
      'Resources/default_pet_audio_config.json'
    ],
    'IMPetAudioSDK' => ['Resources/PrivacyInfo/IMPetAudioSDK/PrivacyInfo.xcprivacy'],
    'TensorFlowLite' => ['Resources/PrivacyInfo/TensorFlowLite/PrivacyInfo.xcprivacy']
  }

  s.dependency 'TensorFlowLiteC', '2.17.0'
end
