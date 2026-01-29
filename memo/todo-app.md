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
- `catch { _ => ...  }`と`catch { _ => return ... }`は意味が違う？
- cliの引数を受け取るにはどうすれば良いか。
- sysパッケージはどこにあるか。
- `Unexpected main function in the non-main package.`
- main.mbtを実行するコマンドは何？
- 他のファイルから関数をインポートするには？
- もっとテストを書きながら進めた方がいいと言う実感はあるけど、具体的にどうすればいいかがわからない
- エラーハンドリングとか、それをユーザー側に伝えるための方法を知らなすぎて、実装イメージが湧いていないのがよくない
- 別のスコープで、同じ名前の変数を宣言して上書きできるやつ、なんて言うんだっけ
- 同じパッケージ内の別ファイルの関数を使えるやつ、ES Modulesの感覚だとグチャグチャになりそうな印象があるけど大丈夫だろうか？そのファイルだけで使用するプライベートな関数って定義できないのかな。
- テストをグルーピングするにはどうすればいいか。
- ブラックボックステストとは何か。
- テストは同一ファイルに書いているが、関数→テスト→関数→テストと近くに書くのと、一番下に書くのとどちらが良いか。
- テストを実行した時に、テストケース名を表示するオプションはあるか。`--verbose`は長すぎるので。

## タスク

- [x] ステップ1 プロジェクト作成
- [x] ステップ2 目標のディレクトリ構成
- [x] ステップ3 データ構造を作る
- [x] ステップ4 CLI実装
- [ ] ステップ5 テストを書く
- [ ] ステップ6 実行
- [ ] ステップ7 仕上げ

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

- [x] args を読む
- [x] add: text を結合して1件追加
- [x] list: 一覧表示（[x] / [ ]）
- [x] done: id指定で完了
- [x]  delete: id指定で削除
- [x] エラー時は使い方を表示

———

## ステップ5: テストを書く (tests/todo_test.mbt)

- [x] parseLine が正しく分解できる
- [x] toLine が同じ形式に戻せる
- [x] done 処理が正しく反映される

———

## ステップ6: 実行・整形・テスト

moon fmt
moon test
moon run src add "buy milk"
moon run src list
moon run src done 1
moon run src list
moon run src delete 1
moon run src list

→シェルスクリプトにしました。

———

## ステップ7: 仕上げ

- README に使い方を簡単に書く
- data/ を .gitignore する（必要なら）

———
