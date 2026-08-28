import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel()
        title.text = "ImageBoard Keyboard"
        title.font = .preferredFont(forTextStyle: .largeTitle)
        title.textAlignment = .center

        let description = UILabel()
        description.text = "画像ベースのカスタムキーボード\nまずキーボードを追加して有効にしてください。"
        description.numberOfLines = 0
        description.textAlignment = .center
        description.textColor = .secondaryLabel

        let settings = UIButton(type: .system)
        settings.setTitle("キーボード設定を開く", for: .normal)
        settings.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        settings.addTarget(self, action: #selector(openKeyboardSettings), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, description, settings])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openKeyboardSettings() {
        guard let url = URL(string: "App-Prefs:root=General&path=Keyboard/Keyboards") else { return }
        UIApplication.shared.open(url)
    }
}
