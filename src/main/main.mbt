///|
type Model = Int

///|
let model : Model = 0

///|
enum Msg {
  Increment
  Decrement
}

///|
fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    Increment => (@tea.none(), model + 1)
    Decrement => (@tea.none(), model - 1)
  }
}

///|
fn view(model : Model) -> @html.Html[Msg] {
  @html.div([
    @html.h1([@html.text(model.to_string())]),
    @html.button(click=Increment, [@html.text("+")]),
    @html.button(click=Decrement, [@html.text("-")]),
  ])
}

///|
fn main {
  @tea.startup(model~, update~, view~)
}
