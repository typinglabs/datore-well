# 作業メモ

### ドキュメント

- ドキュメント
  - [MoonBit Documentation — MoonBit v0.7.1 documentation](https://docs.moonbitlang.com/en/latest/)
- コース
  - [0. Course Overview | Programming with MoonBit: A Modern Approach](https://moonbitlang.github.io/moonbit-textbook/)
- オンラインジャッジ
  - [MoonBit Online Judge](https://oj.moonbitlang.com/problems/202412-002-supply-problem-in-hiking)


### Moonbitのインストール

まずは、Moonbitの環境構築を行ってから、UIを構築するためのライブラリの検証を行う。

Rabbit TEAを使ってみる。

[MoonBit](https://www.moonbitlang.com/download/)

VSCodeのMoonbit拡張機能をインストールする。するとMoonbitのツールチェインをインストールするためのコマンドが追加されるので、コマンドパレットから実行すればOK。

```bash
# helloプロジェクトを作成
moon new hello
cd hello

# コマンドを実行
moon run cmd/main
```

`moon`はいろいろなコマンドを実行できるので、少しずつチェックしていこう。

### Moonbitを書いてみる

ある程度ドキュメントは読んだので、実際にMoonbitのコードを書いて練習していきたい。何か適当なお題を見つけてもらうことにしよう。

MoonbitのドキュメントにCourseとOnline Judgeがあって、ここら辺をやるといいだろうか。習得したいことは

- 基本的な文法でコードを書く
- ビルドシステム、モジュール管理を理解する
- 最低限のmoonサブコマンドを理解する（フォーマット、リント等）
- テストの書き方と実行方法を理解する

あたり。

```
3. シンプルなToDo管理CLI

- 機能: add/list/done/delete
- データ: ローカルファイル保存
- 学び: ファイルI/O、データ構造、モジュール分割
```

を作っていくことにする。

[TODO CLIアプリを作ってみる](./memo.md)

とりあえず完成。いろいろ改善点はあるが、上記の内容については概ね理解できたので次に進む。

### UIフレームワークの検証

Rabbit-TEAと、luna.mbtを使ってみることにする。

→Moonbitのレジストリ（mooncakes.io）がRabbit-TEAで書かれているとのことだったので、それを参考にRabbit-TEAを使って見ることにします。

[moonbitlang/mooncakes.io: website of mooncakes.io, written in MoonBit](https://github.com/moonbitlang/mooncakes.io)

### Rabbit-TEA

[Rabbit-TEA メモ](./rabbit-tea.md)

環境構築は[rabbit-tea-template/package.json at main · moonbit-community/rabbit-tea-template](https://github.com/moonbit-community/rabbit-tea-template)を参考にする。

- `moon.mod.json`を書く
- `bun add -D @tailwindcss/vite rabbit-tea-vite`
- `src/index.html`と`src/style.css`を書く
- `moon add Yoorkin/rabbit-tea`
- `src/main/moon.pkg.json`に`Yoorkin/rabbit-tea`をインポート
- `src/main/main.mbt`を書く
  - めっちゃコンパイルエラー出る。先に`vite`の設定した方がいい？
- `vite.config.js`を書いて、`vite`で開発サーバーを立ち上げて確認
- `vite build`でビルドできることを確認する

![alt text](image.png)

これなんで起きてるんだろう。`moon.pkg.json`は書いてるんだけどね。ビルドはできてるから、LSPの問題な気がする。

`preferred-target`をtypoしていたのが原因だった。moonbitのパッケージとビルド削除してから、`vite dev`してエディタ開き直すと直った。
