///|
pub struct Todo {
  id : Int
  done : Bool
  text : String
} derive(Show, Eq)

///|
pub fn make(id : Int, done : Bool, text : String) -> Todo {
  { id, done, text }
}

///|
pub fn parse_line(line : StringView) -> Todo? {
  let parts = line.split("|").collect()
  if parts.length() != 3 {
    return None
  }
  let id = @strconv.parse_int(parts[0].to_string()) catch { _ => return None }
  let done = match parts[1].to_string() {
    "0" => false
    "1" => true
    _ => return None
  }
  let text = parts[2].to_string()
  Some({ id, done, text })
}

///|
pub fn to_line(todo : Todo) -> String {
  let done = if todo.done { "1" } else { "0" }
  "\{todo.id}|\{done}|\{todo.text}"
}

///|
pub fn load_from_string(content : String) -> Array[Todo] {
  content
    .split("\n")
    .filter_map(line => parse_line(line))
    .collect()
}

///|
pub fn next_id(todos : Array[Todo]) -> Int {
  let mut max_id = 0
  for t in todos {
    if t.id >= max_id {
      max_id = t.id
    }
  }
  max_id + 1
}

///|
pub fn toggle_done(todo : Todo) -> Todo {
  { id: todo.id, done: !todo.done, text: todo.text }
}

///|
test "parse_line/ok" {
  let line = "1|0|ごはんを食べる"
  let task = { id: 1, done: false, text: "ごはんを食べる" }
  assert_eq(parse_line(line), Some(task))
}

///|
test "parse_line/invalid_field_count" {
  assert_eq(parse_line("1|0"), None)
}

///|
test "parse_line/invalid_id" {
  assert_eq(parse_line("x|0|task"), None)
}

///|
test "parse_line/invalid_done" {
  assert_eq(parse_line("1|9|task"), None)
}

///|
test "to_line/ok" {
  let todo = { id: 1, done: false, text: "散歩する" }
  assert_eq(to_line(todo), "1|0|散歩する")
}
