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

- [Introduce The Elm Architecture to MoonBit: build robust web app with simple principles | MoonBit](https://www.moonbitlang.com/blog/rabbit-tea)
- [mooncakes.io](https://mooncakes.io/docs/Yoorkin/rabbit-tea)

とりあえず一つ目の記事を読んでみよう。Elm書いたことあるけどCmdが何かとか覚えていないから、改めてTEAを理解する必要がある。

Rabbit-TEAは、Elmに影響を受けたフロントエンドフレームワーク。TEA = The Elm Architecture。

JavaScriptと比較したメリットとして、パターンマッチがあることが挙げられている。

Elmは純粋関数型で、ステートを変更するのを手続的に書けなくて苦戦した記憶があるから、そこが比較的手軽に書けそうなのはいいかもしれない。

TEAは、Model、View、Updateの3つで構成されている。

Model: アプリケーションを表す状態
View: 状態をHTMLに変換する方法と、ユーザーとのインタラクションを定義する
Update: ユーザーがトリガーしたメッセージを元に、状態を更新する関数

メッセージは、ユーザーが引き起こすイベントの種類のこと。実現したいことが、シンプルなコードで表現されているのが分かる。Cmdについては、後から説明される。

---

Viewは、既存のMoonbitの構文を使ったDSL（EDSLと呼ばれる）なので、コンパイルなどは不要。HTMLタグの属性を指定するときは、Moonbitのラベル付き引数の構文を利用している。

将来的には、JSXライクな構文に置き換えることが考えられている。

TEA、フォームとか実装するの面倒くさそう。

副作用について。外部の状態の変更などの副作用は、Elmと同様にCmdを使って行う。

Cmdは、未実行のアクションを表すもので、Rabbit-TEAのランタイムによって実行される。実行されるタイミングは、UpdateでCmdを返したタイミングかな。

例のコードは、`@http.get`のインターフェイスがちょっと分からない。expect=Text(GotCardText)のところ。

JavaScriptのsetTimeoutを使う例が書かれている。

Moonbitのパッケージレジストリ（mooncakes.io）は、Rabbit-TEAを使って書かれている。

[moonbitlang/mooncakes.io: website of mooncakes.io, written in MoonBit](https://github.com/moonbitlang/mooncakes.io)

Rabbit-TEAの作者の方が書かれているので、Rabbit-TEAの使用例として参考にしたい。
