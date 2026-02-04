///|
enum Screen {
  Top
  Playing
  Result
}

///|
struct Model {
  screen : Screen
}

///|
let model : Model = { screen: Top }

///|
enum Msg {
  Noop
}

///|
fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    Noop => (@tea.none(), model)
  }
}

///|
fn view(model : Model) -> @html.Html[Msg] {
  match model.screen {
    Top => top_screen()
    Playing => playing_screen()
    Result => result_screen()
  }
}

///|
fn main {
  @tea.startup(model~, update~, view~)
}
