# ImageBoard

画像素材をそのまま利用することを目的にした iOS カスタムキーボードです。

## 構成

- `ImageBoard` — ホストアプリ。キーボード設定を開くボタンを提供
- `ImageBoardKeyboard` — `UIInputViewController` ベースの Keyboard Extension
- `project.yml` — XcodeGen プロジェクト定義
- `.github/workflows/build.yml` — GitHub Actions の自動ビルド
- `Tools/prepare_assets.sh` — 画像アーカイブをビルド用リソースへ展開

## キーボード

現在の実装には以下があります。

- 日本語かな配列
- かなフリック入力（上下左右）
- 英字 QWERTY
- 数字・記号配列
- 大文字切替
- バックスペース / 改行 / 空白
- システムキーボード切替（地球儀）
- 元画像を背景に利用するための PNG ローダー

## オリジナル画像の追加

`Images(1).zip` に含まれる PNG はバイナリなので、GitHub の通常の UTF-8 ファイル API では直接登録できません。

ローカルでは、リポジトリ直下に `Images.b64` として ZIP の Base64 を置くか、`ImageBoardKeyboard/Resources/Images/` に PNG を置いてください。

```sh
./Tools/prepare_assets.sh
```

PNG が `ImageBoardKeyboard/Resources/Images/` に存在すれば XcodeGen が Extension にリソースとして組み込みます。

## GitHub Actions

`main` への push または Actions の手動実行で macOS 上で XcodeGen → Release build → unsigned IPA 作成まで自動実行します。

完成した `ImageBoard-unsigned.ipa` は Actions の Artifact から取得できます。

### 実機インストール用署名

現在の CI は Apple 証明書をリポジトリへ保存しない安全な unsigned build です。実機へ配布する場合は、Apple Developer の署名証明書・Provisioning Profile を GitHub Secrets に登録して、署名ジョブを追加してください。
