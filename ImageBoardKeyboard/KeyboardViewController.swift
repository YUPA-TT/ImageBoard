import UIKit

final class KeyboardViewController: UIInputViewController {
    private enum Mode { case kana, letters, numbers }
    private var mode: Mode = .kana
    private var shifted = false
    private var canvas = UIView()
    private var keyboardImageView = UIImageView()
    private var keyButtons: [KeyboardKeyButton] = []

    // Japanese iPhone-style kana/flick layout. The supplied Japanese artwork is the
    // key chrome; these controls are transparent hit areas placed over each key.
    private let kanaRows = [
        ["あ","か","さ","た","な","は","ま","や","ら","わ"],
        ["゛","゜","、","。","「","」","ー","っ","ん"],
        ["小","英数","backspace"],
        ["123","globe","space","return"]
    ]

    // Use the supplied English key-plane artwork for English mode.
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

    // Center, left, down, right, up for a Japanese flick key.
    private let flickMap: [String: [String]] = [
        "あ":["あ","い","う","え","お"],
        "か":["か","き","く","け","こ"],
        "さ":["さ","し","す","せ","そ"],
        "た":["た","ち","つ","て","と"],
        "な":["な","に","ぬ","ね","の"],
        "は":["は","ひ","ふ","へ","ほ"],
        "ま":["ま","み","む","め","も"],
        "や":["や","（","ゆ","）","よ"],
        "ら":["ら","り","る","れ","ろ"],
        "わ":["わ","を","ん","ー","〜"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6

        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        keyboardImageView.translatesAutoresizingMaskIntoConstraints = false
        keyboardImageView.contentMode = .scaleAspectFill
        keyboardImageView.clipsToBounds = true
        canvas.addSubview(keyboardImageView)
        NSLayoutConstraint.activate([
            keyboardImageView.leadingAnchor.constraint(equalTo: canvas.leadingAnchor),
            keyboardImageView.trailingAnchor.constraint(equalTo: canvas.trailingAnchor),
            keyboardImageView.topAnchor.constraint(equalTo: canvas.topAnchor),
            keyboardImageView.bottomAnchor.constraint(equalTo: canvas.bottomAnchor)
        ])

        rebuildKeyboard()
    }

    private var rows: [[String]] {
        switch mode {
        case .kana: return kanaRows
        case .letters: return englishRows
        case .numbers: return numberRows
        }
    }

    private func imageName() -> String {
        switch mode {
        case .kana:
            return "KeyboardLettersKeyPlanePortrait-ja_JP-896h@3x"
        case .letters:
            return "KeyboardLettersKeyPlanePortrait-896h@3x"
        case .numbers:
            return "KeyboardNumbersKeyPlanePortrait-896h@3x"
        }
    }

    private func rebuildKeyboard() {
        keyButtons.forEach { $0.removeFromSuperview() }
        keyButtons.removeAll()

        keyboardImageView.image = UIImage(named: imageName())
            ?? UIImage(named: "KeyboardMainBGPortrait-896h@3x")

        // Coordinates are in the supplied 1242x903 artwork coordinate system.
        // Kana uses the real 10-key / 9-key / special-key arrangement shown by the
        // Japanese artwork instead of pretending it is a QWERTY keyboard.
        let rowRects: [[CGRect]] = [
            (0..<10).map { i in
                CGRect(x: 8 + CGFloat(i) * 124, y: 20, width: 110, height: 130)
            },
            (0..<9).map { i in
                CGRect(x: 8 + CGFloat(i) * 138, y: 184, width: 122, height: 132)
            },
            [
                CGRect(x: 10, y: 348, width: 150, height: 136),
                CGRect(x: 170, y: 348, width: 930, height: 136),
                CGRect(x: 1110, y: 348, width: 122, height: 136)
            ],
            [
                CGRect(x: 10, y: 520, width: 290, height: 130),
                CGRect(x: 325, y: 520, width: 555, height: 130),
                CGRect(x: 895, y: 520, width: 337, height: 130),
                CGRect(x: 895, y: 520, width: 337, height: 130)
            ]
        ]

        for (r, row) in rows.enumerated() {
            for (c, key) in row.enumerated() {
                guard r < rowRects.count, c < rowRects[r].count else { continue }

                let button = KeyboardKeyButton(type: .custom)
                button.key = key
                button.flickOptions = mode == .kana ? flickMap[key] : nil
                button.setTitle(displayTitle(for: key), for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = .systemFont(
                    ofSize: key == "space" ? 15 : 20,
                    weight: .regular
                )
                button.backgroundColor = .clear
                button.accessibilityLabel = displayTitle(for: key)
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                button.normalizedRect = rowRects[r][c]
                canvas.addSubview(button)
                keyButtons.append(button)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard canvas.bounds.width > 0, canvas.bounds.height > 0 else { return }

        let source = CGSize(width: 1242, height: 903)
        let scale = min(canvas.bounds.width / source.width, canvas.bounds.height / source.height)
        let drawn = CGSize(width: source.width * scale, height: source.height * scale)
        let origin = CGPoint(
            x: (canvas.bounds.width - drawn.width) / 2,
            y: (canvas.bounds.height - drawn.height) / 2
        )

        for button in keyButtons {
            let n = button.normalizedRect
            button.frame = CGRect(
                x: origin.x + n.minX * scale,
                y: origin.y + n.minY * scale,
                width: n.width * scale,
                height: n.height * scale
            )
        }
    }

    private func displayTitle(for key: String) -> String {
        switch key {
        case "shift": return "⇧"
        case "backspace": return "⌫"
        case "globe": return "🌐"
        case "return": return "↵"
        case "space": return "空白"
        case "英数": return "ABC"
        default:
            return mode == .letters && shifted ? key.uppercased() : key
        }
    }

    @objc private func keyPressed(_ sender: KeyboardKeyButton) {
        guard let key = sender.key else { return }
        let input = sender.flickedKey ?? key
        sender.flickedKey = nil

        switch key {
        case "backspace":
            textDocumentProxy.deleteBackward()

        case "return":
            textDocumentProxy.insertText("\n")

        case "space", "空白":
            textDocumentProxy.insertText(" ")

        case "globe":
            // This keyboard owns its Japanese/English switch. Do not jump to the
            // next system keyboard when the user taps the globe key.
            switch mode {
            case .kana: mode = .letters
            case .letters: mode = .kana
            case .numbers: mode = .kana
            }
            shifted = false
            rebuildKeyboard()

        case "shift":
            shifted.toggle()
            rebuildKeyboard()

        case "123":
            mode = .numbers
            shifted = false
            rebuildKeyboard()

        case "ABC":
            mode = .letters
            shifted = false
            rebuildKeyboard()

        case "英数":
            mode = .letters
            shifted = false
            rebuildKeyboard()

        case "#+=":
            break

        case "小":
            // The supplied Japanese layout has a dedicated small-character key.
            // Convert the immediately preceding kana when possible; otherwise use
            // the conventional small-tsu fallback.
            if let before = textDocumentProxy.documentContextBeforeInput?.last,
               let small = smallKana[String(before)] {
                textDocumentProxy.deleteBackward()
                textDocumentProxy.insertText(small)
            } else {
                textDocumentProxy.insertText("っ")
            }

        default:
            let value = mode == .letters && shifted ? input.uppercased() : input
            textDocumentProxy.insertText(value)
            if mode == .letters && shifted {
                shifted = false
                rebuildKeyboard()
            }
        }
    }

    private let smallKana: [String: String] = [
        "あ":"ぁ", "い":"ぃ", "う":"ぅ", "え":"ぇ", "お":"ぉ",
        "つ":"っ", "や":"ゃ", "ゆ":"ゅ", "よ":"ょ", "わ":"ゎ"
    ]

    override func textWillChange(_ textInput: UITextInput?) {}
    override func textDidChange(_ textInput: UITextInput?) {}
}

final class KeyboardKeyButton: UIButton {
    var key: String?
    var flickOptions: [String]?
    var flickedKey: String?
    var normalizedRect: CGRect = .zero
    private var touchStart: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchStart = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let options = flickOptions,
           options.count == 5,
           let start = touchStart,
           let end = touches.first?.location(in: self) {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let threshold: CGFloat = 18
            if max(abs(dx), abs(dy)) >= threshold {
                // left/right/down/up around the center.
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
