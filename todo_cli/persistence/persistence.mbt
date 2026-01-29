///|
pub fn load(path : String) -> Array[@todo.Todo] {
  let content = @fs.read_file_to_string(path) catch {
    _ => return @todo.load_from_string("")
  }
  @todo.load_from_string(content)
}

///|
pub fn save(path : String, todos : Array[@todo.Todo]) -> Unit {
  let content = todos.map(todo => @todo.to_line(todo)).join("\n")
  @fs.write_string_to_file(path, content) catch { _ => () }
}
