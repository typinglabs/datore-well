# TODO CLIアプリを作ってみる

- 機能: add/list/done/delete
- データ: ローカルファイル保存
- 学び: ファイルI/O、データ構造、モジュール分割

## 理解したいこと

- 基本的な文法でコードを書く
- ビルドシステム、モジュール管理を理解する
- 最低限のmoonサブコマンドを理解する（フォーマット、リント等）
- テストの書き方と実行方法を理解する

## 疑問点を書き連ねていく

- moon newにテンプレートを指定することはできるか？最小限のものは何か？
- 文字列をsplitする方法
- 文字列を数値に変換する方法
- パッケージをインポートする方法
  - @strcnv.parse_intを使いたい
- 一つのファイルにパッケージをインポートすることはできないのか
- 三項演算子はないのか。
- Arrayにmapはあるか
- 関数の引数は、StringとStringViewどちらにするのが良いか。Stringで書いているが、計算しているとStringViewがよく出てくる。
- StringView型にString型を渡せるか。渡せるっぽい。
- Option型で、SomeかNoneかを判別する方法。
- Array[T?]をfilterでArray[T]に絞り込めないのか？これはfilter_mapを使うといいらしい。
- ファイルを読み込む方法。
- パッケージをインストールする方法。
  - [moonbitlang/x Now Supports File I/O | MoonBit](https://www.moonbitlang.com/blog/io-support)
  - `moon add moonbitlang/x`
- `moonbitlang/x`は何か

## タスク

- [x] ステップ1 プロジェクト作成
- [x] ステップ2 目標のディレクトリ構成
- [x] ステップ3 データ構造を作る
- [ ] ステップ4
- [ ] ステップ5
- [ ] ステップ6
- [ ] ステップ7

書いたテストが実行されないが、この原因は何か？

→パッケージとして認識されていないから。Moonbitは`moon.pkg.json`があるディレクトリのみをパッケージとして認識する。

## 実装ステップ

全体像（最小仕様）

- コマンド: add, list, done, delete
- 保存: data/todo.txt に1行1タスク
- フォーマット: id|done|text
    - 例: 3|0|buy milk

———

## ステップ1: 新規プロジェクト作成

moon new todo-cli
cd todo-cli

※ moon new が無ければ moon init など、手元のドキュメントに合わせてください。

———

## ステップ2: 目標のディレクトリ構成

todo-cli/
  src/
    main.mbt
    todo.mbt
  tests/
    todo_test.mbt
  data/
    todo.txt   (空でOK)

———

## ステップ3: データ構造を作る (src/todo.mbt)

- Todo 型（id, done, text）
- parseLine(line) -> Todo?
- toLine(todo) -> String
- load(path) -> List<Todo>
- save(path, todos)

———

## ステップ4: CLI実装 (src/main.mbt)

- args を読む
- add: text を結合して1件追加
- list: 一覧表示（[x] / [ ]）
- done: id指定で完了
- delete: id指定で削除
- エラー時は使い方を表示

———

## ステップ5: テストを書く (tests/todo_test.mbt)

- parseLine が正しく分解できる
- toLine が同じ形式に戻せる
- done 処理が正しく反映される

———

## ステップ6: 実行・整形・テスト

moon fmt
moon test
moon run -- add "buy milk"
moon run -- list
moon run -- done 1

※ moon run の仕様が違う場合は moon help を確認。

———

## ステップ7: 仕上げ

- README に使い方を簡単に書く
- data/ を .gitignore する（必要なら）

———
