import UIKit

final class KeyboardViewController: UIInputViewController {
    private let rows: [[String]] = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["⇧","z","x","c","v","b","n","m","⌫"],
        ["123","🌐","space","return"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        buildKeyboard()
    }

    private func buildKeyboard() {
        view.backgroundColor = .clear
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4)
        ])

        for row in rows {
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.spacing = 4
            rowView.distribution = .fillEqually
            for title in row {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: title == "space" ? 15 : 20)
                button.backgroundColor = UIColor.secondarySystemBackground
                button.layer.cornerRadius = 5
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                button.accessibilityIdentifier = title
                rowView.addArrangedSubview(button)
            }
            stack.addArrangedSubview(rowView)
        }
    }

    @objc private func keyPressed(_ sender: UIButton) {
        guard let key = sender.accessibilityIdentifier else { return }
        switch key {
        case "⌫": textDocumentProxy.deleteBackward()
        case "return": textDocumentProxy.insertText("\n")
        case "space": textDocumentProxy.insertText(" ")
        case "⇧": break
        case "123": break
        case "🌐": advanceToNextInputMode()
        default: textDocumentProxy.insertText(key)
        }
    }

    override func textWillChange(_ textInput: UITextInput?) {}
    override func textDidChange(_ textInput: UITextInput?) {}
}
