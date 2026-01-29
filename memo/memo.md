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