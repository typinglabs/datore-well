///|
let data_path = "data/todo.txt"

///|
fn add_cmd(todo : String) -> Unit {
  let text = todo.trim()
  if text == "" {
    println("todo text is required")
    return
  }
  let todos = load(data_path)
  let next_id = {
    let mut max_id = 0
    for t in todos {
      if t.id >= max_id {
        max_id = t.id
      }
    }
    max_id + 1
  }
  todos.push({ id: next_id, done: false, text: text.to_string() })
  save(data_path, todos)
  println("added \{next_id}")
}

///|
fn list_cmd() -> Unit {
  let todos = load(data_path)
  if todos.length() == 0 {
    println("no todos")
    return
  }
  for t in todos {
    let mark = if t.done { "x" } else { " " }
    println("[\{mark}] \{t.id} \{t.text}")
  }
}

///|
fn done_cmd(todo_id : String) -> Bool {
  let todo_id = @strconv.parse_int(todo_id) catch { _ => return false }
  let todos = load(data_path)
  let index = todos.search_by(todo => todo.id == todo_id)
  match index {
    None => {
      println("todo not found: \{todo_id}")
      false
    }
    Some(index) => {
      todos[index] = { ..todos[index], done: !todos[index].done }
      save(data_path, todos)
      true
    }
  }
}

///|
fn delete_cmd(todo_id : String) -> Bool {
  let todo_id = @strconv.parse_int(todo_id) catch { _ => return false }
  let todos = load(data_path)
  let new_todos = todos.filter(todo => todo.id != todo_id)
  if new_todos.length() == todos.length() {
    println("todo not found: \{todo_id}")
    return false
  }
  save(data_path, new_todos)
  true
}

///|
fn usage() -> Unit {
  println("usage:")
  println("  todo add <text>")
  println("  todo list")
  println("  todo done <id>")
  println("  todo delete <id>")
}

///|
fn handle_args(args : Array[String]) -> Int {
  if args.length() < 2 {
    usage()
    return 1
  }
  match args[1] {
    "add" => {
      if args.length() < 3 {
        usage()
        return 1
      }
      add_cmd(args[2])
      0
    }
    "list" => {
      list_cmd()
      0
    }
    "done" => {
      if args.length() < 3 {
        usage()
        return 1
      }
      if done_cmd(args[2]) {
        0
      } else {
        1
      }
    }
    "delete" => {
      if args.length() < 3 {
        usage()
        return 1
      }
      if delete_cmd(args[2]) {
        0
      } else {
        1
      }
    }
    _ => {
      usage()
      1
    }
  }
}

///|
test "handle_args / add / ok" {
  assert_eq(handle_args(["/path", "add", "\"add milk\""]), 0)
}

///|
test "handle_args / add / error_if_task_name_is_missing" {
  assert_eq(handle_args(["/path", "add"]), 1)
}

///|
test "handle_args / list / ok" {
  let code = handle_args(["/path", "list"])
  assert_eq(code, 0)
}

///|
test "handle_args / done / ok" {
  let code = handle_args(["/path", "done", "1"])
  assert_eq(code, 0)
}

///|
test "handle_args / done / error_if_id_is_invalid" {
  let code = handle_args(["/path", "done", "2"])
  assert_eq(code, 1)
}

///|
test "handle_args / delete / ok" {
  let code = handle_args(["/path", "delete", "1"])
  assert_eq(code, 0)
}

///|
test "handle_args / delete / error_if_id_is_invalid" {
  let code = handle_args(["/path", "delete", "1"])
  assert_eq(code, 1)
}

///|
fn main {
  let args = @sys.get_cli_args()
  @sys.exit(handle_args(args))
}
