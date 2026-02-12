///|
enum Category {
  All
  Kanji
  Katakana
  Hiragana
} derive(Show, Eq)

///|
struct TopModel {
  typing_input : String
  is_input_ready : Bool
  filtered_words : Array[WordItem]
}

///|
struct TypingModel {
  timer : Timer
  typing_input : String
  is_typing_active : Bool
  filtered_words : Array[WordItem]
  word_queue : Array[WordItem]
  typing_session : TypingSession?
  awaiting_space : Bool
  completed_display : String
  completed_roman : String
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
fn init_top_model(form : Form) -> TopModel {
  let filtered_words = filter_words(form.category, form.filter)
  {
    typing_input: "",
    is_input_ready: true,
    filtered_words: filtered_words |> shuffle_word_items(1),
  }
}

///|
let model : Model = {
  screen: Top(init_top_model({ time_seconds: 60, category: All, filter: "" })),
  form: { time_seconds: 60, category: All, filter: "" },
}

///|
enum Msg {
  Init
  // Top
  SelectTime(Int)
  SelectCategory(Category)
  UpdateFilter(String)
  StartFromInput(String)
  // Playing
  UpdateTyping(String)
  Tick
  Focused
  Blurred
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
extern "js" fn install_focus_blur(
  id : String,
  on_focus : () -> Unit,
  on_blur : () -> Unit,
) =
  #|(id, onFocus, onBlur) => {
  #|  const el = document.getElementById(id);
  #|  if (!el) return;
  #|  const defer = (fn) => setTimeout(fn, 0);
  #|  el.addEventListener('focus', () => defer(onFocus));
  #|  el.addEventListener('blur', () => defer(onBlur));
  #|}

///|
extern "js" fn focus_input(id : String) =
  #|(id) => {
  #|  const el = document.getElementById(id);
  #|  if (el && typeof el.focus === 'function') {
  #|    el.focus();
  #|  }
  #|}

///|
fn focus_input_cmd() -> @cmd.Cmd[Msg] {
  @cmd.batch([
    @cmd.Cmd(fn(events) {
      install_focus_blur(
        "typing-input",
        fn() { events.trigger_update(Focused) },
        fn() { events.trigger_update(Blurred) },
      )
    }),
    @cmd.Cmd(fn(_) { focus_input("typing-input") }),
  ])
}

///|
fn update(msg : Msg, model : Model) -> (@cmd.Cmd[Msg], Model) {
  match (msg, model.screen) {
    (Init, _) => (focus_input_cmd(), model)
    // Top
    (SelectTime(value), Top(_)) =>
      (@cmd.none(), { ..model, form: { ..model.form, time_seconds: value } })
    (SelectCategory(value), Top(top_model)) => {
      let filtered_words = filter_words(value, model.form.filter)
      (
        @cmd.none(),
        {
          form: { ..model.form, category: value },
          screen: Top({
            ..top_model,
            filtered_words: filtered_words |> shuffle_word_items(1),
          }),
        },
      )
    }
    (UpdateFilter(value), Top(top_model)) => {
      let filtered_words = filter_words(model.form.category, value)
      (
        @cmd.none(),
        {
          form: { ..model.form, filter: value },
          screen: Top({
            ..top_model,
            filtered_words: filtered_words |> shuffle_word_items(1),
          }),
        },
      )
    }
    (StartFromInput(value), Top(top_model)) =>
      if value != "" && top_model.filtered_words.length() > 0 {
        let (cmd, typing_model) = start_session(
          model.form,
          top_model.filtered_words,
          value,
        )
        (
          @cmd.batch([cmd, focus_input_cmd()]),
          { ..model, screen: Typing(typing_model) },
        )
      } else {
        (@cmd.none(), model)
      }
    (Focused, Top(top_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Top({ ..top_model, is_input_ready: true }) },
      )
    (Blurred, Top(top_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Top({ ..top_model, is_input_ready: false }) },
      )
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
      (focus_input_cmd(), { ..model, screen: Top(init_top_model(model.form)) })
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
  let app = @tea.new(model~, update~, view~)
  app.dispatch(Init)
}
