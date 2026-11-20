# IMPetAudioSDK

INMO X 宠物声音识别 / 猫狗叫声语义翻译 SDK 的 **静态 XCFramework**：纯离线、无 UI。输入 16 kHz 单声道 `Int16` PCM，返回是否有猫狗叫声、物种、叫声类型、语义码、声学特征与风格提示。推理用内置 YAMNet（tflite）。

pod 自带 `TensorFlowLite.xcframework`（TensorFlow Lite 2.17.0 的 Swift 接口，静态），依赖 `TensorFlowLiteC` 2.17.0。不需要 clone tensorflow 仓库。

---

## 环境要求

- iOS 15.0+
- Swift 5
- Xcode 15+
- CocoaPods，并开启 `use_frameworks!`
- `pod install` 时能访问 `dl.google.com`（下载 TensorFlowLiteC）

## 安装

```ruby
platform :ios, '15.0'
use_frameworks! :linkage => :static

target 'YourApp' do
  pod 'IMPetAudioSDK', :git => 'https://github.com/INMO-X/IMPetAudioSDK.git', :tag => '0.1.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
```

**不要同时引入官方 `TensorFlowLiteSwift` pod**：它也提供 `TensorFlowLite` 模块，会冲突。

```swift
import IMPetAudioSDK

let sdk = try PetAudioSDK()                     // 后台队列创建并复用
let result = try sdk.analyzeClip(pcm: pcm)      // 后台队列调用
print(result.isPetSound, result.petType as Any, result.meaning.meaningCode)
```

## 隐私

默认不联网，音频只在内存中处理。可选的识别上报默认关闭，开启后只上报版本元数据。详见 [docs/PRIVACY.md](docs/PRIVACY.md)。

## 示例

[Example/](Example/) 用 tag `0.1.2` 创建 SDK、显示模型和配置版本，并分析一段合成音频（预期结果是没有猫狗叫声），验证资源加载和 TFLite 推理。

```bash
cd Example
pod install
open IMPetAudioSDK.xcworkspace
```

## 文档

| 文档 | 说明 |
|------|------|
| [docs/USAGE.md](docs/USAGE.md) | 场景用法 |
| [docs/PRIVACY.md](docs/PRIVACY.md) | 隐私清单、数据处理与宿主配置 |

## License

SDK：MIT。第三方：YAMNet 模型与 TensorFlow Lite 均为 Apache License 2.0，见 [Resources/YAMNET_MODEL_NOTICE.md](Resources/YAMNET_MODEL_NOTICE.md) 和 [ThirdPartyNotices/](ThirdPartyNotices/)。
