# IMPetAudioSDK Example

可运行 Demo，依赖公开仓 tag `0.1.2` 的 IMPetAudioSDK 静态库（自带 TensorFlowLite.xcframework，依赖 TensorFlowLiteC 2.17.0）。

```bash
cd Example
pod install
open IMPetAudioSDK.xcworkspace
```

选择 scheme **IMPetAudioSDK_Example**。启动后在后台创建 SDK，显示模型、配置和分类器版本；点按钮分析一段 2 秒 440 Hz 合成音频，预期 `isPetSound == false`，用来验证资源加载和 TFLite 推理。不需要麦克风权限。

`pod install` 需要能访问 `dl.google.com`。本地未推送 tag 时，把 Podfile 里的 `:git` 行换成注释中的 `:path`。
