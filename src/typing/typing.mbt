///|
struct RomanState {
  typed_roman : String
  remaining_roman : String
  typed_kana : String
  remaining_kana : String
} derive(Show, Eq)

///|
enum RomanResult {
  CorrectKey // 正しいキーを入力
  WrongKey // 間違ったキーを入力
  WordCompleted // 正しいキーを入力して、完了
} derive(Show, Eq)

///|
type InitFn = (String) -> RomanState

///|
type ApplyKeyFn = (RomanState, Char) -> (RomanState, RomanResult) raise Error

///|
struct RomanEngine {
  graph : Graph
  current : NodeId
}

///|
fn create_apply_key_fn(kana : String) -> ApplyKeyFn raise Error {
  let (graph, dist) = build_graph_from_kana_with_dist(kana)
  let initial_node_id = get_node_id({ kana_index: 0, buffer: "" })
  let mut engine : RomanEngine = { graph, current: initial_node_id }
  fn apply_key(
    state : RomanState,
    key : Char,
  ) -> (RomanState, RomanResult) raise Error {

    // keyが正しいかどうか判定
    // graph[current]のedgesに、keyが含まれているかどうか
    let mut next_node = None
    for edge in engine.graph[engine.current] {
      if edge.pressed_key == key {
        next_node = Some(from_node_id(edge.to))
      }
    }
    match next_node {
      None => (state, WrongKey)
      Some(next_node) => {
        // 最短経路と違う場合は、それを更新する
        engine = { ..engine, current: get_node_id(next_node) }

        // stateを更新する
        // TODO: remainig_romanを更新する
        let next_state : RomanState = {
          ..state,
          typed_roman: state.typed_roman + key.to_string(),
          typed_kana: kana[:][0:next_node.kana_index].to_string(),
          remaining_kana: kana[:][next_node.kana_index:].to_string(),
        }
        let result : RomanResult = if next_node.kana_index < kana.length() {
          CorrectKey
        } else {
          WordCompleted
        }
        (next_state, result)
      }
    }
  }

  return apply_key
}

///|
test "正解かどうかを判定できる きゅう -> kyuuは正解" {
  let kana = "きゅう"
  let apply_key = create_apply_key_fn(kana)
  let initial_state : RomanState = {
    typed_roman: "",
    remaining_roman: "", // TODO:
    typed_kana: "",
    remaining_kana: kana,
  }

  // kyuuと入力する
  let (state, result) = apply_key(initial_state, 'k')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'y')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'u')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key(state, 'u')
  assert_eq(result, WordCompleted)
}

///|
test "正解かどうか判定できる きゅう -> kilyuuは正解" {
  let kana = "きゅう"
  let apply_key = create_apply_key_fn(kana)
  let initial_state : RomanState = {
    typed_roman: "",
    remaining_roman: "", // TODO:
    typed_kana: "",
    remaining_kana: kana,
  }

  // kilyuuと入力する
  let (state, result) = apply_key(initial_state, 'k')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'i')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'l')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'y')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'u')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key(state, 'u')
  assert_eq(result, WordCompleted)
}

///|
test "正解かどうか判定できる きゅう -> kaは不正解" {
  let kana = "きゅう"
  let apply_key = create_apply_key_fn(kana)
  let initial_state : RomanState = {
    typed_roman: "",
    remaining_roman: "", // TODO:
    typed_kana: "",
    remaining_kana: kana,
  }

  // kilyuuと入力する
  let (_, result) = apply_key(initial_state, 'k')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key(initial_state, 'a')
  assert_eq(result, WrongKey)
}

///|
test "入力したローマ字を取得できる きゅう -> kyuu" {
  let kana = "きゅう"
  let apply_key = create_apply_key_fn(kana)
  let initial_state : RomanState = {
    typed_roman: "",
    remaining_roman: "", // TODO:
    typed_kana: "",
    remaining_kana: kana,
  }

  // kyuuと入力する
  let (state, _result) = apply_key(initial_state, 'k')
  assert_eq(state.typed_roman, "k")
  let (state, _result) = apply_key(state, 'y')
  assert_eq(state.typed_roman, "ky")
  let (state, _result) = apply_key(state, 'u')
  assert_eq(state.typed_roman, "kyu")
  let (state, _result) = apply_key(state, 'u')
  assert_eq(state.typed_roman, "kyuu")
}
