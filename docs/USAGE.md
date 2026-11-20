# IMPetAudioSDK 使用说明

宠物声音识别 / 猫狗叫声语义翻译 SDK：纯离线、无 UI。输入一段 16 kHz 单声道 `Int16` PCM，返回是否有猫狗叫声、物种、叫声类型、语义码、声学特征与风格提示。推理用内置 YAMNet（tflite）。

## 安装

```ruby
platform :ios, '15.0'
use_frameworks! :linkage => :static   # dynamic 也可以

target 'YourApp' do
  pod 'IMPetAudioSDK', :git => 'https://github.com/INMO-X/IMPetAudioSDK.git', :tag => '0.1.2'
end
```

pod 会带上：

| 内容 | 说明 |
|------|------|
| `IMPetAudioSDK.xcframework` | SDK 本体（静态） |
| `TensorFlowLite.xcframework` | TensorFlow Lite Swift 接口（静态，Apache-2.0），模块名 `TensorFlowLite` |
| `TensorFlowLiteC` 2.17.0 | 依赖 pod，从 Google CDN 下载的 C 推理库 |
| `IMPetAudioSDKResources.bundle` | `yamnet.tflite`（约 4.1 MB）、标签表、默认配置 |

不要再单独引入官方 `TensorFlowLiteSwift` pod：它也提供 `TensorFlowLite` 模块，会和 SDK 自带的重复。

国内网络下 `dl.google.com` 可能下载失败，`pod install` 时需要能访问 Google CDN（或配置代理）。

```swift
import IMPetAudioSDK
```

## 1. 创建 SDK

```swift
let sdk = try PetAudioSDK()   // 等价于 reportingConfiguration: nil，不联网
```

`init` 会校验模型 SHA-256 并解析内置配置，**放后台队列懒创建，复用同一实例**。

## 2. 分析一段音频

```swift
let work = DispatchQueue(label: "pet.audio", qos: .userInitiated)
work.async {
    do {
        let result = try sdk.analyzeClip(pcm: pcm,
                                         sampleRateHz: PetAudioContract.sampleRateHz,   // 16_000
                                         channels: PetAudioContract.channels)           // 1
        DispatchQueue.main.async { render(result) }
    } catch let error as PetAudioError {
        print(error.code, error.message)
    } catch {
        print(error)
    }
}
```

- `pcm` 为 `[Int16]`，必须是 16 kHz 单声道；SDK 只校验参数、不重采样。建议不少于 1 s，最长 30 s。
- `analyzeClip` 同步、CPU 密集，不要在主线程调用；同一实例的调用用一条串行队列承接。

## 3. 读结果

```swift
guard result.isPetSound, let petType = result.petType else { return }   // 没检出猫狗叫声
print(petType, result.petSoundType as Any, result.detectorConfidence)

switch result.meaning.meaningLevel {
case .fine, .coarse: print(result.meaning.meaningCode)   // 如 "HAPPY"，文案由接入方映射
case .unknown:       print("没听懂")
}
if result.diagnostics.contains(.poorSignalQuality) { /* 提示靠近重录 */ }
```

## 4. 只要语义（可选）

接入方自己做了检测门时，可以跳过 YAMNet：

```swift
let meaning = try sdk.fineMeaning(pcm: clip)
```

## 5. 配置热替换（可选）

```swift
let applied = sdk.applyConfig(fileURL: url)   // 或 applyConfig(data:)
if !applied.success { print(applied.errorCode as Any, applied.errorMessage as Any) }
try sdk.resetToBundledConfig()
let info = try sdk.runtimeInfo()              // 模型 / 配置 / 分类器版本与 SHA-256
```

## 6. 识别上报（可选，默认关闭）

```swift
let reporting = PetAudioReportingConfiguration(baseURL: URL(string: "https://api.example.com")!) {
    currentJWT()   // 返回带 sub 的 JWT；nil 时不发送
}
let sdk = try PetAudioSDK(reportingConfiguration: reporting)
```

开启后每次 `analyzeClip` 成功向 `<baseURL>/api/v1/pet-audio/recognition-events` POST 一条版本元数据，不含音频和识别结果。详见 [PRIVACY.md](PRIVACY.md)。

## 7. 释放

```swift
sdk.close()   // 不可逆；之后调用抛 .sdkClosed
```

## 错误码

`analyzeClip` 可能抛出的 `PetAudioErrorCode`：`sdkClosed`、`emptyPCM`、`unsupportedSampleRate`、`unsupportedChannels`、`clipTooLong`、`modelInitFailed`、`modelInferenceFailed`。`init` 失败时不一定是 `PetAudioError`，按 `Error` 兜底。

各结果字段的含义见 Xcode 中 Jump to Definition 打开的接口文档注释。
