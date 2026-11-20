# Privacy（IMPetAudioSDK）

框架自带的隐私清单，以及宿主 App 仍需自己配置的部分。

## 隐私清单（`PrivacyInfo.xcprivacy`）

源码路径：`Sources/IMPetAudioSDK/Resources/PrivacyInfo.xcprivacy`。

| Key | 取值 |
|-----|------|
| `NSPrivacyTracking` | `false`。框架不做跨 App / 网站追踪。 |
| `NSPrivacyTrackingDomains` | 空。 |
| `NSPrivacyCollectedDataTypes` | `NSPrivacyCollectedDataTypeProductInteraction`：仅在宿主传入 `PetAudioReportingConfiguration` 开启识别上报时发生，每次识别成功上报一条版本元数据；关联用户（请求带 JWT，按 `sub` 区分待发队列）、不用于追踪，目的是分析（Analytics）。 |
| `NSPrivacyAccessedAPITypes` | 见下表。 |

| API | 原因码 | 代码里的用途 |
|-----|--------|----------------|
| System boot time（`ProcessInfo.systemUptime`） | `35F9.1` | `YamnetClassifier` 计算单次推理耗时（`inferenceTimeMs`）。只在 App 内计时，不上报绝对值。 |

不读 UserDefaults、文件时间戳、磁盘空间。

## 数据处理

- **音频**：只在内存中处理，不落盘、不上传、不持久化特征。
- **默认不联网**：`PetAudioSDK()` / `reportingConfiguration: nil` 时不发起任何网络请求。
- **识别上报（可选）**：开启后上报内容仅为事件 ID、时间戳、配置文件名、配置 / 分类器 / 特征 schema 版本与 SHA-256、SDK 版本；不含音频、不含识别结果。待发事件缓存在 `Library/Application Support/IMPetAudioSDK/recognition-events/`，默认最多 100 条、7 天，发送成功后删除。

宿主若不开启上报，可以在 App Store 隐私标签里不勾选「产品交互」，但 SDK 清单里的声明会出现在 Xcode 生成的隐私报告中，属正常现象。

## 二进制消费者拿到清单的位置

1. **每个 XCFramework 切片内**：`IMPetAudioSDK.framework/PrivacyInfo.xcprivacy`、`TensorFlowLite.framework/PrivacyInfo.xcprivacy`。
2. **CocoaPods resource bundle**：`IMPetAudioSDK.bundle`、`TensorFlowLite.bundle`。静态链接不会把 framework 目录嵌进 App，清单放在资源包根目录，随 `[CP] Copy Pods Resources` 进包。
3. `TensorFlowLiteC` 的清单随它自己的 pod（`TensorFlowLiteC.bundle`）进包。

TensorFlowLite（Swift 接口）的清单沿用上游：不追踪、不收集、不访问 Required Reason API。

## 宿主仍需自己声明的部分

- SDK 只接收宿主传入的 PCM，不直接访问麦克风。宿主录音时配置 `NSMicrophoneUsageDescription`。
- 开启识别上报时，在隐私政策里说明上报内容与服务端地址。

## 第三方许可

- YAMNet 模型（Apache License 2.0）：`Resources/YAMNET_MODEL_NOTICE.md`、`Resources/TensorFlow-Models-Apache-2.0.txt`。
- TensorFlow Lite Swift / C（Apache License 2.0）：`ThirdPartyNotices/TensorFlow-Apache-2.0.txt`。

对外发布 App 时请保留以上声明。
