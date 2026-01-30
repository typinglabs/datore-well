///|
struct Model {
  count : Int
}

///|
enum Msg {
  Increment
  Decrement
}

///|
fn update(msg : Msg) -> (Cmd[Msg], Model) {
  match msg {
    Increment => (none(), { count: model.count + 1 })
    Decrement => (none(), { count: model.count - 1 })
  }
}

///|
fn view(model : Model) -> Html[Msg] {
  div([text("\{model.count}")])
}

///|
fn main {
  let model = { count: 0 }
  @tea.startup(model~, update~, view~)
}
