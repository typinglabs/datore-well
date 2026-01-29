///|
struct Todo {
  id : Int
  done : Bool
  text : String
} derive(Show, Eq)

///|
test "parse_line / ok" {
  let task_line : String = "1|0|ごはんを食べる"
  let task : Todo = { id: 1, done: false, text: "ごはんを食べる" }
  assert_eq(parse_line(task_line), Some(task))
}

///|
test "parse_line / invalid_field_count" {
  assert_eq(parse_line("1|0"), None)
}

///|
test "parse_line / invalid_id" {
  assert_eq(parse_line("x|0|task"), None)
}

///|
test "parse_line / invalid_done" {
  assert_eq(parse_line("1|9|task"), None)
}

///|
fn parse_line(line : StringView) -> Todo? {
  let parts = line.split("|").collect()
  if parts.length() != 3 {
    return None
  }
  let id = @strconv.parse_int(parts[0]) catch { _ => return None }
  let done = match parts[1] {
    "0" => false
    "1" => true
    _ => return None
  }
  let text = parts[2].to_string()
  Some({ id, done, text })
}

///|
test "to_line / ok" {
  let todo : Todo = { id: 1, done: false, text: "散歩する" }
  assert_eq(to_line(todo), "1|0|散歩する")
}

///|
fn to_line(todo : Todo) -> String {
  let done = if todo.done { "1" } else { "0" }
  "\{todo.id}|\{done}|\{todo.text}"
}

///|
test "load_from_string / ok" {
  let content = ["1|0|a", "2|0|b"].join("\n")
  let todos = load_from_string(content)
  assert_eq(todos.length(), 2)
}

///|
test "load_from_string / skip_empty_line" {
  let content = ["1|0|a", "", "2|0|b", ""].join("\n")
  let todos = load_from_string(content)
  assert_eq(todos.length(), 2)
}

///|
fn load_from_string(content : String) -> Array[Todo] {
  let lines = content.split("\n")
  let todos = lines.filter_map(line => parse_line(line)).collect()
  todos
}

///|
fn load(path : String) -> Array[Todo] {
  // TODO: エラーハンドリング
  let content = @fs.read_file_to_string(path) catch { _ => return [] }
  load_from_string(content)
}

///|
fn save(path : String, todos : Array[Todo]) -> Unit {
  // TODO: エラーハンドリング
  let content = todos.map(todo => to_line(todo)).join("\n")
  @fs.write_string_to_file(path, content) catch {
    _ => ()
  }
}
