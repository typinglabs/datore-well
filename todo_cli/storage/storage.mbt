///|
pub struct Storage {
  load : () -> Array[@todo.Todo]
  save : (Array[@todo.Todo]) -> Unit
}

///|
pub fn make_storage(path : String) -> Storage {
  fn load() -> Array[@todo.Todo] {
    let content = @fs.read_file_to_string(path) catch {
      _ => return @todo.load_from_string("")
    }
    @todo.load_from_string(content)
  }

  fn save(todos : Array[@todo.Todo]) -> Unit {
    let content = todos.map(todo => @todo.to_line(todo)).join("\n")
    @fs.write_string_to_file(path, content) catch {
      _ => ()
    }
  }

  { load, save }
}

///|
priv struct Counter {
  increment : () -> Int
}

///|
fn make_counter() -> Counter {
  let mut count = 0
  fn increment() {
    count = count + 1
    count
  }

  { increment, }
}

///|
let counter : Counter = make_counter()

///|
pub fn make_tmp_path() -> String {
  "data/tmp_" + (counter.increment)().to_string() + ".txt"
}
