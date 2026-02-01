///|
struct Node {
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
struct Edge {
  to : NodeId
  pressed_key : Char
} derive(Show)

///|
type Graph = Map[NodeId, Array[Edge]]

///|
fn build_graph_from_kana(kana : String) -> Graph raise Error {
  let graph = {}
  let start_node : Node = { kana_index: 0, buffer: "" }

  // 幅優先探索する
  let queue = @queue.new()
  queue.push(start_node)
  while queue.pop() is Some(node) {
    let node_id = get_node_id(node)

    // 遷移
    for key = 'a'; key <= 'z'; key = Int::unsafe_to_char(key.to_int() + 1) {
      let result = process(node.buffer, key)
      // result.outputが、kanaに一致していることが必要条件
      let ok = kana[:][node.kana_index:].has_prefix(result.output)
      if !ok {
        continue
      }

      // 逆向きに辺を張る next_node -> node
      let next_node : Node = {
        buffer: result.buffer,
        kana_index: node.kana_index + result.output.length(),
      }
      let next_node_id = get_node_id(next_node)
      let edge : Edge = { to: node_id, pressed_key: key }
      match graph.get(next_node_id) {
        None => graph.set(next_node_id, [edge])
        Some(edges) => edges.push(edge)
      }

      // next_nodeをキューに追加
      queue.push(next_node)
    }
  }

  // ゴールから逆向きに辿って、有効な頂点のみを残す

  return graph
}

///|
test "build_kana_graph" {
  let graph = build_graph_from_kana("きゅう")
  inspect(graph)
}
