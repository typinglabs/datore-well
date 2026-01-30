# Rabbit-TEA

## 分からないこと

- rabbit-TEAをインストールする方法は？

## 始め方

- [moonbit-community/rabbita: A simple, declarative, functional web UI framework](https://github.com/moonbit-community/rabbita?tab=readme-ov-file)
- [moonbit-community/rabbit-tea-template: a MoonBit web app template using Rabbit-TEA with TailwindCSS](https://github.com/moonbit-community/rabbit-tea-template)

Vite、TailwindCSSのテンプレートがあるので、それを真似すれば良さそう。これはRabbit-TEAの作者の方によるもの。

パッケージのバージョンは古そうなので、適宜アップデートする。

テンプレートをもとにプロジェクトを作れるかもしれないが、それほど量も多くないので、理解のため1つずつファイルを作ってみる。

ディレクトリは浅い方が好きなので`src/`ディレクトリはなくてもいいのだが、後で問題が起きるかもしれないのでとりあえず真似しておく。

rabbit-TEAのインストール周りで苦戦している。`moon add`で追加して、`moon.pkg.json`に追加したものの、存在しない扱いされている。

aliases.mbtが必要だったらしい。ここは理解していないのでまた今度。とりあえずカウンターが動いたのでここまでとしよう。

## ビルド時のエラー対応（メモ）

### 症状

`bun run build` で以下のエラーが出る。

```
Error: ENOENT: no such file or directory, lstat 'target/js/release/build/main/main.js.map'
```

### 原因

rabbit-tea-vite が `moon build --release` 実行後に `main.js.map` を無条件でコピーしようとしており、`main.js.map` が生成されない環境だと失敗する。

### 暫定対処

`rabbit-tea-vite` の `runMoonbitBuild` 内で `main.js.map` の存在確認を行い、無い場合はコピーをスキップする。

- `sample_webapp/node_modules/rabbit-tea-vite/dist/index.js`
- `sample_webapp/node_modules/rabbit-tea-vite/src/index.ts`

## ドキュメントを読む

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
