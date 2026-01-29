# TODO CLIアプリを作ってみる

- 機能: add/list/done/delete
- データ: ローカルファイル保存
- 学び: ファイルI/O、データ構造、モジュール分割

## 理解したいこと

- 基本的な文法でコードを書く
- ビルドシステム、モジュール管理を理解する
- 最低限のmoonサブコマンドを理解する（フォーマット、リント等）
- テストの書き方と実行方法を理解する

## わからないこと

- moon newにテンプレートを指定することはできるか？最小限のものは何か？

## タスク

- [ ] ステップ1
- [ ] ステップ2
- [ ] ステップ3
- [ ] ステップ4
- [ ] ステップ5
- [ ] ステップ6
- [ ] ステップ7

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
