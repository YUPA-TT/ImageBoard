import UIKit

final class KeyboardViewController: UIInputViewController {
    private enum Mode { case kana, letters, numbers }
    private var mode: Mode = .kana
    private var shifted = false
    private var canvas: UIView!
    private var keyboardImageView: UIImageView!
    private var keyButtons: [KeyboardKeyButton] = []

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
        "あ":["あ","い","う","え","お"],"か":["か","き","く","け","こ"],
        "さ":["さ","し","す","せ","そ"],"た":["た","ち","つ","て","と"],
        "な":["な","に","ぬ","ね","の"],"は":["は","ひ","ふ","へ","ほ"],
        "ま":["ま","み","む","め","も"],"や":["や","（","ゆ","）","よ"],
        "ら":["ら","り","る","れ","ろ"],"わ":["わ","を","ん","ー","〜"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        canvas = UIView(frame: .zero)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        keyboardImageView = UIImageView(frame: .zero)
        keyboardImageView.translatesAutoresizingMaskIntoConstraints = false
        keyboardImageView.contentMode = .scaleAspectFit
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
        switch mode { case .kana: return kanaRows; case .letters: return englishRows; case .numbers: return numberRows }
    }

    private func imageName() -> String {
        switch mode {
        case .kana: return "KeyboardLettersKeyPlanePortrait-ja_JP-896h@3x"
        case .letters: return "KeyboardLettersKeyPlanePortrait-896h@3x"
        case .numbers: return "KeyboardNumbersKeyPlanePortrait-896h@3x"
        }
    }

    private func rebuildKeyboard() {
        keyButtons.forEach { $0.removeFromSuperview() }
        keyButtons.removeAll()
        keyboardImageView.image = UIImage(named: imageName()) ?? UIImage(named: "KeyboardMainBGPortrait-896h@3x")

        // The supplied Apple keyboard artwork is 1242x903 (@3x). These normalized
        // rectangles line up with its four visible key rows, so the artwork supplies
        // the exact key chrome while transparent controls supply interaction/text.
        let normalizedRows: [[CGRect]] = [
            (0..<10).map { i in CGRect(x: 8 + CGFloat(i) * 124, y: 20, width: 110, height: 130) },
            (0..<9).map { i in CGRect(x: 8 + CGFloat(i) * 138, y: 184, width: 122, height: 132) },
            (0..<9).map { i in CGRect(x: 10 + CGFloat(i) * 138, y: 348, width: 122, height: 136) },
            [CGRect(x: 10,y:520,width:290,height:130),CGRect(x:325,y:520,width:555,height:130),CGRect(x:895,y:520,width:337,height:130)]
        ]

        let currentRows = rows
        for (r, row) in currentRows.enumerated() {
            for (c, key) in row.enumerated() {
                let button = KeyboardKeyButton(type: .custom)
                button.key = key
                button.flickOptions = flickMap[key]
                button.setTitle(displayTitle(for: key), for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: key == "space" ? 15 : 20, weight: .regular)
                button.backgroundColor = .clear
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                canvas.addSubview(button)
                let rect: CGRect
                if r < 3, c < normalizedRows[r].count { rect = normalizedRows[r][c] }
                else if r == 3 {
                    let base = normalizedRows[3]
                    if c < 3 { rect = base[c] } else { rect = CGRect(x: 0,y:0,width:0,height:0) }
                } else { rect = CGRect(x:0,y:0,width:0,height:0) }
                button.normalizedRect = rect
                keyButtons.append(button)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Convert the source-artwork pixel coordinate system into the actual view.
        let source = CGSize(width: 1242, height: 903)
        let scale = min(canvas.bounds.width / source.width, canvas.bounds.height / source.height)
        let drawn = CGSize(width: source.width * scale, height: source.height * scale)
        let origin = CGPoint(x: (canvas.bounds.width - drawn.width) / 2, y: (canvas.bounds.height - drawn.height) / 2)
        for button in keyButtons {
            let n = button.normalizedRect
            button.frame = CGRect(x: origin.x + n.minX * scale, y: origin.y + n.minY * scale, width: n.width * scale, height: n.height * scale)
        }
    }

    private func displayTitle(for key: String) -> String {
        switch key { case "shift": return "⇧"; case "backspace": return "⌫"; case "globe": return "🌐"; case "return": return "↵"; case "space": return "空白"; default: return mode == .letters && shifted ? key.uppercased() : key }
    }

    @objc private func keyPressed(_ sender: KeyboardKeyButton) {
        guard let key = sender.key else { return }
        let input = sender.flickedKey ?? key
        sender.flickedKey = nil
        switch key {
        case "backspace": textDocumentProxy.deleteBackward()
        case "return": textDocumentProxy.insertText("\n")
        case "space", "空白": textDocumentProxy.insertText(" ")
        case "globe": advanceToNextInputMode()
        case "shift": shifted.toggle(); rebuildKeyboard()
        case "123": mode = .numbers; rebuildKeyboard()
        case "ABC", "英数": mode = .letters; rebuildKeyboard()
        case "#+=": break
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
    var normalizedRect: CGRect = .zero
    private var touchStart: CGPoint?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { super.touchesBegan(touches, with:event); touchStart = touches.first?.location(in:self) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let options = flickOptions, options.count == 5, let start = touchStart, let end = touches.first?.location(in:self) {
            let dx=end.x-start.x, dy=end.y-start.y, threshold: CGFloat=18
            if max(abs(dx),abs(dy)) >= threshold { flickedKey = abs(dx)>abs(dy) ? (dx > 0 ? options[3] : options[1]) : (dy > 0 ? options[2] : options[4]) }
            else { flickedKey=options[0] }
        }
        touchStart=nil
        super.touchesEnded(touches, with:event)
    }
}
