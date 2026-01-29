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
fn done_cmd(todo_id : String) -> Unit {
  let todo_id = @strconv.parse_int(todo_id) catch { _ => return }
  let todos = load(data_path)
  let index = todos.search_by(todo => todo.id == todo_id)
  match index {
    None => println("todo not found: \{todo_id}")
    Some(index) => {
      todos[index] = { ..todos[index], done: !todos[index].done }
      save(data_path, todos)
    }
  }
}

///|
fn delete_cmd(todo_id : String) -> Unit {
  let todo_id = @strconv.parse_int(todo_id) catch { _ => return }
  let todos = load(data_path)
  let new_todos = todos.filter(todo => todo.id != todo_id)
  save(data_path, new_todos)
}

///|
fn main {
  let args = @sys.get_cli_args()
  match args[1] {
    "add" => add_cmd(args[2])
    "list" => list_cmd()
    "done" => done_cmd(args[2])
    "delete" => delete_cmd(args[2])
    _ => ()
  }
}
