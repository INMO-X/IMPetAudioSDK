import UIKit
import IMPetAudioSDK

final class ViewController: UIViewController {

    private let infoLabel = UILabel()
    private let work = DispatchQueue(label: "com.inmo.example.petaudio", qos: .userInitiated)
    private var sdk: PetAudioSDK?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IMPetAudioSDK"
        view.backgroundColor = .systemBackground

        infoLabel.numberOfLines = 0
        infoLabel.font = .preferredFont(forTextStyle: .footnote)
        infoLabel.text = "初始化中…"

        let analyzeButton = UIButton(type: .system, primaryAction: UIAction(title: "分析 2 秒合成音频") { [weak self] _ in
            self?.analyzeSynthetic()
        })

        let stack = UIStackView(arrangedSubviews: [analyzeButton, infoLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        work.async { [weak self] in
            let text: String
            do {
                let sdk = try PetAudioSDK()
                let info = try sdk.runtimeInfo()
                self?.sdk = sdk
                text = """
                模型：\(info.modelVersion)
                配置：\(info.configVersion)（\(info.configSource.rawValue)）
                分类器：\(info.classifierVersion)
                """
            } catch {
                text = "初始化失败：\(error.localizedDescription)"
            }
            DispatchQueue.main.async { self?.infoLabel.text = text }
        }
    }

    /// 440 Hz 正弦波，预期没有猫狗叫声；用来验证资源加载与 TFLite 推理。
    private func analyzeSynthetic() {
        work.async { [weak self] in
            guard let sdk = self?.sdk else { return }
            let rate = Double(PetAudioContract.sampleRateHz)
            let pcm: [Int16] = (0..<Int(rate * 2)).map { i in
                Int16(sin(2 * .pi * 440 * Double(i) / rate) * 8_000)
            }
            let text: String
            do {
                let result = try sdk.analyzeClip(pcm: pcm)
                text = """
                isPetSound：\(result.isPetSound)
                petType：\(result.petType?.rawValue ?? "-")
                meaning：\(result.meaning.meaningCode)（\(result.meaning.meaningLevel.rawValue)）
                YAMNet 推理：\(result.inferenceTimeMs) ms
                diagnostics：\(result.diagnostics.map(\.rawValue).sorted().joined(separator: ", "))
                """
            } catch {
                text = "分析失败：\(error.localizedDescription)"
            }
            DispatchQueue.main.async { self?.infoLabel.text = text }
        }
    }
}
