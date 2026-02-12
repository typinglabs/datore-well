///|
enum Category {
  All
  Kanji
  Katakana
  Hiragana
} derive(Show, Eq)

///|
struct TopModel {
  // フォーム
  time_seconds : Int
  category : Category
  filter : String
  // タイピング
  typing_input : String
  // フラグ
  is_typing_active : Bool
  is_input_ready : Bool
}

///|
struct TypingModel {
  // フォーム
  time_seconds : Int
  category : Category
  filter : String
  // タイマー
  timer : Timer
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
  // フォーム
  time_seconds : Int
  category : Category
  filter : String
  // タイマー
  timer : Timer
  // 打鍵数、ミス数
  hits : Int
  miss : Int
}

///|
enum NewScreen {
  Top(TopModel)
  Typing(TypingModel)
  Result(ResultModel)
}

///|
struct NewModel {
  screen : NewScreen
  // TODO: フォームのデータをここに移動する
  form : String
}

///|
let model : NewModel = {
  screen: Top({
    time_seconds: 60,
    category: All,
    filter: "",
    typing_input: "",
    is_typing_active: false,
    is_input_ready: true,
  }),
  form: "",
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
fn update(msg : Msg, model : NewModel) -> (@cmd.Cmd[Msg], NewModel) {
  match (msg, model.screen) {
    // Top
    (SelectTime(value), Top(top_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Top({ ..top_model, time_seconds: value }) },
      )
    (SelectCategory(value), Top(top_model)) =>
      (@cmd.none(), { ..model, screen: Top({ ..top_model, category: value }) })
    (UpdateFilter(value), Top(top_model)) =>
      (@cmd.none(), { ..model, screen: Top({ ..top_model, filter: value }) })
    (StartFromInput(value), Top(top_model)) =>
      if value != "" {
        let (cmd, started_model) = start_session(top_model)
        (
          cmd,
          { ..model, screen: Typing(apply_typing_input(started_model, value)) },
        )
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
        (@cmd.none(), { ..model, screen: Result(typing_to_result(next_model)) })
      }
    }
    // Result / Common
    (GoTitle, screen) =>
      (@cmd.none(), { ..model, screen: Top(to_top_model(screen)) })
    (SelectTime(value), Typing(typing_model)) =>
      (
        @cmd.none(),
        {
          ..model,
          screen: Typing({
            ..typing_model,
            time_seconds: value,
            timer: create_timer(value * 1000),
          }),
        },
      )
    (SelectTime(value), Result(result_model)) =>
      (
        @cmd.none(),
        {
          ..model,
          screen: Result({
            ..result_model,
            time_seconds: value,
            timer: create_timer(value * 1000),
          }),
        },
      )
    (SelectCategory(value), Typing(typing_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Typing({ ..typing_model, category: value }) },
      )
    (SelectCategory(value), Result(result_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Result({ ..result_model, category: value }) },
      )
    (UpdateFilter(value), Typing(typing_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Typing({ ..typing_model, filter: value }) },
      )
    (UpdateFilter(value), Result(result_model)) =>
      (
        @cmd.none(),
        { ..model, screen: Result({ ..result_model, filter: value }) },
      )
    (_, _) => (@cmd.none(), model)
  }
}

///|
struct TypingSession {
  word : WordItem
  kanji_state : @romaji_typing.KanjiState
  apply_key : @romaji_typing.ApplyKanjiKeyFn
}

///|
fn init_typing_session(word : WordItem) -> TypingSession? {
  try {
    let (kanji_state, apply_key) = @romaji_typing.create_kanji_engine(
      word.annotated,
    )
    Some({ word, kanji_state, apply_key })
  } catch {
    _ => None
  }
}

///|
fn init_session_from_queue(queue : Array[WordItem]) -> TypingSession? {
  if queue.length() == 0 {
    None
  } else {
    init_typing_session(queue[0])
  }
}

///|
fn typing_to_result(model : TypingModel) -> ResultModel {
  {
    time_seconds: model.time_seconds,
    category: model.category,
    filter: model.filter,
    timer: model.timer,
    hits: model.hits,
    miss: model.miss,
  }
}

///|
fn to_top_model(screen : NewScreen) -> TopModel {
  match screen {
    Top(top_model) =>
      { ..top_model, is_typing_active: false, is_input_ready: true }
    Typing(typing_model) =>
      {
        time_seconds: typing_model.time_seconds,
        category: typing_model.category,
        filter: typing_model.filter,
        typing_input: "",
        is_typing_active: false,
        is_input_ready: true,
      }
    Result(result_model) =>
      {
        time_seconds: result_model.time_seconds,
        category: result_model.category,
        filter: result_model.filter,
        typing_input: "",
        is_typing_active: false,
        is_input_ready: true,
      }
  }
}

///|
fn apply_typing_input(model : TypingModel, value : String) -> TypingModel {
  if !model.is_typing_active {
    return { ..model, typing_input: value }
  }
  let key = last_char(value)
  match key {
    None => { ..model, typing_input: value }
    Some(ch) =>
      if model.awaiting_space {
        if ch == ' ' {
          let next_model = advance_to_next_word(model)
          { ..next_model, typing_input: "", hits: model.hits + 1 }
        } else {
          { ..model, typing_input: "" }
        }
      } else if ch == ' ' {
        { ..model, typing_input: "" }
      } else {
        let next_model = match model.typing_session {
          None => model
          Some(session) =>
            try {
              let (next_state, result) = (session.apply_key)(ch)
              match result {
                WordCompleted =>
                  {
                    ..model,
                    typing_session: None,
                    awaiting_space: true,
                    completed_display: model.completed_display +
                    session.word.display,
                    completed_roman: model.completed_roman +
                    next_state.typed_romaji,
                    hits: model.hits + 1,
                  }
                WrongKey => { ..model, miss: model.miss + 1 }
                CorrectKey =>
                  {
                    ..model,
                    typing_session: Some({ ..session, kanji_state: next_state }),
                    hits: model.hits + 1,
                  }
              }
            } catch {
              _ => model
            }
        }
        { ..next_model, typing_input: "" }
      }
  }
}

///|
fn start_session(model : TopModel) -> (@cmd.Cmd[Msg], TypingModel) {
  let queue = build_word_queue(10)
  let typing_session = init_session_from_queue(queue)
  let timer = start_timer(create_timer(model.time_seconds * 1000))
  (
    schedule_tick(1000),
    {
      time_seconds: model.time_seconds,
      category: model.category,
      filter: model.filter,
      timer,
      typing_input: "",
      is_typing_active: true,
      word_queue: queue,
      typing_session,
      awaiting_space: false,
      completed_display: "",
      completed_roman: "",
      hits: 0,
      miss: 0,
    },
  )
}

///|
fn advance_to_next_word(model : TypingModel) -> TypingModel {
  let mut completed_display = model.completed_display
  let mut completed_roman = model.completed_roman
  if model.word_queue.length() > 1 {
    completed_display += " "
    completed_roman += " "
  }
  let queue = advance_word_queue(model.word_queue)
  let typing_session = init_session_from_queue(queue)
  {
    ..model,
    word_queue: queue,
    typing_session,
    awaiting_space: false,
    completed_display,
    completed_roman,
  }
}

///|
fn last_char(value : String) -> Char? {
  match value[:] {
    [] => None
    [.., last] => Some(last)
  }
}

///|
fn view(model : NewModel) -> @html.Html[Msg] {
  match model.screen {
    Top(top_model) => top_screen(top_model)
    Typing(typing_model) => playing_screen(typing_model)
    Result(result_model) => result_screen(result_model)
  }
}

///|
fn main {
  @tea.startup(model~, update~, view~)
}
