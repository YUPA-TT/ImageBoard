import UIKit

final class KeyboardViewController: UIInputViewController {
    private enum Mode { case kana, letters, numbers }

    private var mode: Mode = .kana
    private var shifted = false
    private var rootStack: UIStackView!
    private var backgroundImageView: UIImageView!

    private let kanaRows = [
        ["あ","か","さ","た","な","は","ま","や","ら","わ"],
        ["゛","゜","、","。","「","」","ー","っ","ん"],
        ["小","ABC","英数","backspace"],
        ["123","globe","space","return"]
    ]

    private let englishRows = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["shift","z","x","c","v","b","n","m","backspace"],
        ["123","globe","space","return"]
    ]

    private let numberRows = [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","¥","&","@","\""],
        ["#+=",".",",","?","!","'","backspace"],
        ["ABC","globe","space","return"]
    ]

    private let flickMap: [String: [String]] = [
        "あ": ["あ","い","う","え","お"],
        "か": ["か","き","く","け","こ"],
        "さ": ["さ","し","す","せ","そ"],
        "た": ["た","ち","つ","て","と"],
        "な": ["な","に","ぬ","ね","の"],
        "は": ["は","ひ","ふ","へ","ほ"],
        "ま": ["ま","み","む","め","も"],
        "や": ["や","（","ゆ","）","よ"],
        "ら": ["ら","り","る","れ","ろ"],
        "わ": ["わ","を","ん","ー","〜"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        rebuildKeyboard()
    }

    private func configureView() {
        view.backgroundColor = .systemGray6

        backgroundImageView = UIImageView(frame: .zero)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "KeyboardMainBGPortrait-896h@3x")
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.spacing = 6
        rootStack.distribution = .fillEqually
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
        ])

        let height = view.heightAnchor.constraint(equalToConstant: 265)
        height.priority = .defaultHigh
        height.isActive = true
    }

    private func rebuildKeyboard() {
        rootStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let rows: [[String]]
        switch mode {
        case .kana: rows = kanaRows
        case .letters: rows = englishRows
        case .numbers: rows = numberRows
        }

        for row in rows {
            let rowView = UIStackView()
            rowView.axis = .horizontal
            rowView.spacing = 4
            rowView.distribution = .fillEqually
            for key in row {
                let button = KeyboardKeyButton(type: .system)
                button.key = key
                button.flickOptions = flickMap[key]
                button.setTitle(displayTitle(for: key), for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: key == "space" ? 15 : 20)
                button.setTitleColor(.label, for: .normal)
                button.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.96)
                button.layer.cornerRadius = 5
                button.layer.masksToBounds = true
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                rowView.addArrangedSubview(button)
            }
            rootStack.addArrangedSubview(rowView)
        }
    }

    private func displayTitle(for key: String) -> String {
        switch key {
        case "shift": return "⇧"
        case "backspace": return "⌫"
        case "globe": return "🌐"
        case "return": return "↵"
        case "space": return "空白"
        default:
            if mode == .letters && shifted { return key.uppercased() }
            return key
        }
    }

    @objc private func keyPressed(_ sender: KeyboardKeyButton) {
        guard let key = sender.key else { return }
        let input = sender.flickedKey ?? key
        sender.flickedKey = nil

        switch key {
        case "backspace": textDocumentProxy.deleteBackward()
        case "return": textDocumentProxy.insertText("\n")
        case "space": textDocumentProxy.insertText(" ")
        case "globe": advanceToNextInputMode()
        case "shift":
            shifted.toggle()
            rebuildKeyboard()
        case "123":
            mode = .numbers
            rebuildKeyboard()
        case "ABC":
            mode = .letters
            rebuildKeyboard()
        case "英数":
            mode = .letters
            rebuildKeyboard()
        case "#+=": break
        case "空白": textDocumentProxy.insertText(" ")
        case "小": textDocumentProxy.insertText("っ")
        default:
            textDocumentProxy.insertText(mode == .letters && shifted ? input.uppercased() : input)
            if mode == .letters && shifted { shifted = false; rebuildKeyboard() }
        }
    }

    override func textWillChange(_ textInput: UITextInput?) {}
    override func textDidChange(_ textInput: UITextInput?) {}
}

final class KeyboardKeyButton: UIButton {
    var key: String?
    var flickOptions: [String]?
    var flickedKey: String?
    private var touchStart: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchStart = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let options = flickOptions, options.count == 5,
           let start = touchStart, let end = touches.first?.location(in: self) {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let threshold: CGFloat = 18
            if max(abs(dx), abs(dy)) >= threshold {
                if abs(dx) > abs(dy) {
                    flickedKey = dx > 0 ? options[3] : options[1]
                } else {
                    flickedKey = dy > 0 ? options[2] : options[4]
                }
            } else {
                flickedKey = options[0]
            }
        }
        touchStart = nil
        super.touchesEnded(touches, with: event)
    }
}
