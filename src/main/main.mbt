///|
enum Screen {
  Top
  Playing
  Result
} derive(Show, Eq)

///|
enum Category {
  All
  Kanji
  Katakana
  Hiragana
} derive(Show, Eq)

///|
struct Model {
  screen : Screen
  time_seconds : Int
  category : Category
  filter : String
  typing_input : String
} derive(Show, Eq)

///|
let model : Model = {
  screen: Top,
  time_seconds: 60,
  category: All,
  filter: "",
  typing_input: "",
}

///|
enum Msg {
  Start
  GoTitle
  GoResult
  SelectTime(Int)
  SelectCategory(Category)
  UpdateFilter(String)
  UpdateTyping(String)
}

///|
fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    Start => (@tea.none(), { ..model, screen: Playing })
    GoTitle => (@tea.none(), { ..model, screen: Top })
    GoResult => (@tea.none(), { ..model, screen: Result })
    SelectTime(value) => (@tea.none(), { ..model, time_seconds: value })
    SelectCategory(value) => (@tea.none(), { ..model, category: value })
    UpdateFilter(value) => (@tea.none(), { ..model, filter: value })
    UpdateTyping(value) => (@tea.none(), { ..model, typing_input: value })
  }
}

///|
fn view(model : Model) -> @html.Html[Msg] {
  match model.screen {
    Top => top_screen(model)
    Playing => playing_screen(model)
    Result => result_screen(model)
  }
}

///|
fn main {
  @tea.startup(model~, update~, view~)
}
