///|
priv struct Node {
  // どこまで入力したか
  kana_index : Int
  // 未変換の文字列
  buffer : String
}

///|
type NodeId = String

///|
fn get_node_id(node : Node) -> NodeId {
  return "\{node.kana_index}|\{node.buffer}"
}

///|
priv suberror NodeIdParseError

///|
fn from_node_id(node_id : String) -> Node raise Error {
  match node_id.split("|").collect() {
    [kana_index_str, buffer] =>
      {
        kana_index: @strconv.parse_int(kana_index_str),
        buffer: buffer.to_string(),
      }
    _ => raise NodeIdParseError
  }
}

///|
struct Edge {
  to : NodeId
  pressed_key : Char
} derive(Show)

///|
type Graph = Map[NodeId, Array[Edge]]

///|
fn build_graph_from_kana(kana : String) -> Graph raise Error {
  let graph : Graph = Map::new()
  let start_node : Node = { kana_index: 0, buffer: "" }
  let view = kana[:]
  let len = view.length()

  // 幅優先探索する
  let queue = @queue.new()
  let visited : Map[NodeId, Bool] = Map::new()
  queue.push(start_node)
  while queue.pop() is Some(node) {
    let node_id = get_node_id(node)
    if visited.contains(node_id) {
      continue
    }
    visited[node_id] = true

    // 遷移
    for key = 'a'; key <= 'z'; key = Int::unsafe_to_char(key.to_int() + 1) {
      let result = process(node.buffer, key)

      // result.outputが、kanaに一致していることが必要条件
      guard node.kana_index <= len else {
        abort("kana_index out of range: \{node.kana_index} > \{len}")
      }
      let ok = view[node.kana_index:].has_prefix(result.output)
      if !ok {
        continue
      }

      // 逆向きに辺を張る next_node -> node
      let advance = result.output[:].length()
      let next_node : Node = {
        buffer: result.buffer,
        kana_index: node.kana_index + advance,
      }
      let next_node_id = get_node_id(next_node)
      let edge : Edge = { to: node_id, pressed_key: key }
      match graph.get(next_node_id) {
        None => graph.set(next_node_id, [edge])
        Some(edges) => edges.push(edge)
      }

      // next_nodeをキューに追加
      if !visited.contains(next_node_id) {
        queue.push(next_node)
      }
    }
  }

  // ゴールから逆向きに辿って、有効な頂点のみを残す
  let graph_normal : Graph = Map::new()
  let start_node : Node = { kana_index: len, buffer: "" }
  let queue = @queue.new()
  let visited_reverse : Map[NodeId, Bool] = Map::new()
  queue.push(start_node)
  while queue.pop() is Some(node) {
    let from = get_node_id(node)
    if visited_reverse.contains(from) {
      continue
    }
    visited_reverse[from] = true
    let edges = match graph.get(from) {
      None => continue
      Some(edges) => edges
    }
    for edge in edges {
      // edge.to -> node
      let reverse_edge : Edge = { ..edge, to: from }
      match graph_normal.get(edge.to) {
        None => graph_normal.set(edge.to, [reverse_edge])
        Some(edges) => edges.push(reverse_edge)
      }
      queue.push(from_node_id(edge.to))
    }
  }
  return graph_normal
}

///|
test "build_kana_graph" {
  let graph = build_graph_from_kana("きゅう")
  assert_true(graph.contains("0|"))
  assert_true(graph.contains("2|"))
  inspect(
    graph,
    content=(
      #|{"2|": [{to: "3|", pressed_key: 'u'}, {to: "2|w", pressed_key: 'w'}], "2|w": [{to: "3|", pressed_key: 'u'}, {to: "2|wh", pressed_key: 'h'}], "2|wh": [{to: "3|", pressed_key: 'u'}], "0|ky": [{to: "2|", pressed_key: 'u'}], "1|ly": [{to: "2|", pressed_key: 'u'}], "1|xy": [{to: "2|", pressed_key: 'u'}], "0|k": [{to: "0|ky", pressed_key: 'y'}, {to: "1|", pressed_key: 'i'}], "1|l": [{to: "1|ly", pressed_key: 'y'}], "1|x": [{to: "1|xy", pressed_key: 'y'}], "0|": [{to: "0|k", pressed_key: 'k'}], "1|": [{to: "1|l", pressed_key: 'l'}, {to: "1|x", pressed_key: 'x'}]}
    ),
  )
}
