///|
enum Category {
  All
  Kanji
  Katakana
  Hiragana
} derive(Show, Eq)

///|
struct TopModel {
  // タイピング
  typing_input : String
  // フラグ
  is_typing_active : Bool
  is_input_ready : Bool
}

///|
struct TypingModel {
  // タイマー
  timer : Timer
  // タイピング
  typing_input : String
  // フラグ
  is_typing_active : Bool
  // ワード
  word_queue : Array[WordItem]
  // タイピング情報
  typing_session : TypingSession?
  awaiting_space : Bool
  // 入力済み
  completed_display : String
  completed_roman : String
  // 打鍵数とミス数
  hits : Int
  miss : Int
}

///|
struct ResultModel {
  // タイマー
  timer : Timer
  // 打鍵数、ミス数
  hits : Int
  miss : Int
}

///|
enum Screen {
  Top(TopModel)
  Typing(TypingModel)
  Result(ResultModel)
}

///|
struct Form {
  time_seconds : Int
  category : Category
  filter : String
}

///|
struct Model {
  screen : Screen
  form : Form
}

///|
let model : Model = {
  screen: Top({
    typing_input: "",
    is_typing_active: false,
    is_input_ready: true,
  }),
  form: { time_seconds: 60, category: All, filter: "" },
}

///|
enum Msg {
  // Top
  SelectTime(Int)
  SelectCategory(Category)
  UpdateFilter(String)
  StartFromInput(String)
  // Playing
  UpdateTyping(String)
  Tick
  // Result
  GoTitle
}

///|
extern "js" fn set_timeout(f : () -> Unit, ms : Int) = "(f,ms) => setTimeout(f, ms)"

///|
fn schedule_tick(ms : Int) -> @cmd.Cmd[Msg] {
  @cmd.Cmd(fn(events) { set_timeout(fn() { events.trigger_update(Tick) }, ms) })
}

///|
fn update(msg : Msg, model : Model) -> (@cmd.Cmd[Msg], Model) {
  match (msg, model.screen) {
    // Top
    (SelectTime(value), Top(_)) =>
      (@cmd.none(), { ..model, form: { ..model.form, time_seconds: value } })
    (SelectCategory(value), Top(_)) =>
      (@cmd.none(), { ..model, form: { ..model.form, category: value } })
    (UpdateFilter(value), Top(_)) =>
      (@cmd.none(), { ..model, form: { ..model.form, filter: value } })
    (StartFromInput(value), Top(_)) =>
      if value != "" {
        let (cmd, typing_model) = start_session(model.form, value)
        (cmd, { ..model, screen: Typing(typing_model) })
      } else {
        (@cmd.none(), model)
      }
    // Typing
    (UpdateTyping(value), Typing(typing_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Typing(apply_typing_input(typing_model, value)) },
      )
    (Tick, Typing(typing_model)) => {
      // タイマーを1減らして、0になったら次の画面に進むだけなんだけどなぁ(何でこんな実装に...)
      let next_timer = tick_timer(typing_model.timer, 1000)
      let next_model = {
        ..typing_model,
        timer: next_timer,
        is_typing_active: if is_finished(next_timer) {
          false
        } else {
          typing_model.is_typing_active
        },
      }
      if !is_finished(next_timer) {
        (schedule_tick(1000), { ..model, screen: Typing(next_model) })
      } else {
        (
          @cmd.none(),
          {
            ..model,
            screen: Result({
              timer: typing_model.timer,
              hits: typing_model.hits,
              miss: typing_model.miss,
            }),
          },
        )
      }
    }
    // Result
    (GoTitle, _) =>
      (
        @cmd.none(),
        {
          ..model,
          screen: Top({
            typing_input: "",
            is_typing_active: false,
            is_input_ready: true,
          }),
        },
      )
    (_, _) => (@cmd.none(), model)
  }
}

///|
fn view(model : Model) -> @html.Html[Msg] {
  match model.screen {
    Top(top_model) => top_screen(top_model, model.form)
    Typing(typing_model) => playing_screen(typing_model)
    Result(result_model) => result_screen(result_model)
  }
}

///|
fn main {
  @tea.startup(model~, update~, view~)
}
