///|
type Storage = @storage.Storage

///|
fn add_cmd(storage : Storage, todo : String) -> Unit {
  let text = todo.trim()
  if text == "" {
    println("todo text is required")
    return
  }
  let todos : Array[@todo.Todo] = (storage.load)()
  let next_id = @todo.next_id(todos)
  todos.push(@todo.make(next_id, false, text.to_string()))
  (storage.save)(todos)
  println("added \{next_id}")
}

///|
fn list_cmd(storage : Storage) -> Unit {
  let todos : Array[@todo.Todo] = (storage.load)()
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
fn done_cmd(storage : Storage, todo_id : String) -> Bool {
  let todo_id = @strconv.parse_int(todo_id) catch { _ => return false }
  let todos : Array[@todo.Todo] = (storage.load)()
  let index = todos.search_by(todo => todo.id == todo_id)
  match index {
    None => {
      println("todo not found: \{todo_id}")
      false
    }
    Some(index) => {
      todos[index] = @todo.toggle_done(todos[index])
      (storage.save)(todos)
      true
    }
  }
}

///|
fn delete_cmd(storage : Storage, todo_id : String) -> Bool {
  let todo_id = @strconv.parse_int(todo_id) catch { _ => return false }
  let todos : Array[@todo.Todo] = (storage.load)()
  let new_todos = todos.filter(todo => todo.id != todo_id)
  if new_todos.length() == todos.length() {
    println("todo not found: \{todo_id}")
    return false
  }
  (storage.save)(new_todos)
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
fn handle_args(args : Array[String], storage : Storage) -> Int {
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
      add_cmd(storage, args[2])
      0
    }
    "list" => {
      list_cmd(storage)
      0
    }
    "done" => {
      if args.length() < 3 {
        usage()
        return 1
      }
      if done_cmd(storage, args[2]) {
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
      if delete_cmd(storage, args[2]) {
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
  let path = @storage.make_tmp_path()
  let storage = @storage.make_storage(path)
  assert_eq(handle_args(["/path", "add", "add milk"], storage), 0)
  @fs.remove_file(path) catch {
    _ => ()
  }
}

///|
test "handle_args / add / error_if_task_name_is_missing" {
  let path = @storage.make_tmp_path()
  let storage = @storage.make_storage(path)
  assert_eq(handle_args(["/path", "add"], storage), 1)
  @fs.remove_file(path) catch {
    _ => ()
  }
}

///|
test "handle_args / list / ok" {
  let path = @storage.make_tmp_path()
  let storage = @storage.make_storage(path)
  let code = handle_args(["/path", "list"], storage)
  assert_eq(code, 0)
  //
  @fs.remove_file(path) catch {
    _ => ()
  }
}

///|
test "handle_args / done / ok" {
  let path = @storage.make_tmp_path()
  let seed = @todo.load_from_string("1|0|task")
  let storage = @storage.make_storage(path)
  (storage.save)(seed)
  let code = handle_args(["/path", "done", "1"], storage)
  assert_eq(code, 0)
  @fs.remove_file(path) catch {
    _ => ()
  }
}

///|
test "handle_args / done / error_if_id_is_invalid" {
  let path = @storage.make_tmp_path()
  let seed = @todo.load_from_string("1|0|task")
  let storage = @storage.make_storage(path)
  (storage.save)(seed)
  let code = handle_args(["/path", "done", "2"], storage)
  assert_eq(code, 1)
  @fs.remove_file(path) catch {
    _ => ()
  }
}

///|
test "handle_args / delete / ok" {
  let path = @storage.make_tmp_path()
  let seed = @todo.load_from_string("1|0|task")
  let storage = @storage.make_storage(path)
  (storage.save)(seed)
  let code = handle_args(["/path", "delete", "1"], storage)
  assert_eq(code, 0)
  @fs.remove_file(path) catch {
    _ => ()
  }
}

///|
test "handle_args / delete / error_if_id_is_invalid" {
  let path = @storage.make_tmp_path()
  let storage = @storage.make_storage(path)
  let code = handle_args(["/path", "delete", "1"], storage)
  assert_eq(code, 1)
  @fs.remove_file(path) catch {
    _ => ()
  }
}

///|
fn main {
  let args = @sys.get_cli_args()
  let data_path = "data/todo.txt"
  @sys.exit(handle_args(args, @storage.make_storage(data_path)))
}
