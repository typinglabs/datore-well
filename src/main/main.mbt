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
  timer : Timer
  category : Category
  filter : String
  typing_input : String
  is_typing_active : Bool
  is_input_ready : Bool
  next_word_index : Int
  word_queue : Array[WordItem]
  typing_session : TypingSession?
  awaiting_space : Bool
  completed_display : String
  completed_roman : String
  hits : Int
  miss : Int
}

///|
let model : Model = {
  screen: Top,
  time_seconds: 60,
  timer: create_timer(60 * 1000),
  category: All,
  filter: "",
  typing_input: "",
  is_typing_active: false,
  is_input_ready: true,
  next_word_index: 0,
  word_queue: [],
  typing_session: None,
  awaiting_space: false,
  completed_display: "",
  completed_roman: "",
  hits: 0,
  miss: 0,
}

///|
enum Msg {
  Start
  StartFromInput(String)
  GoTitle
  GoResult
  SelectTime(Int)
  SelectCategory(Category)
  UpdateFilter(String)
  UpdateTyping(String)
  StartTyping
  StopTyping
  Tick
}

///|
extern "js" fn set_timeout(f : () -> Unit, ms : Int) = "(f,ms) => setTimeout(f, ms)"

///|
fn schedule_tick(ms : Int) -> @cmd.Cmd[Msg] {
  @cmd.Cmd(fn(events) { set_timeout(fn() { events.trigger_update(Tick) }, ms) })
}

///|
fn update(msg : Msg, model : Model) -> (@cmd.Cmd[Msg], Model) {
  match msg {
    Start => start_session(model)
    StartFromInput(value) =>
      if model.screen == Top && value != "" {
        let (cmd, started_model) = start_session(model)
        (cmd, apply_typing_input(started_model, value))
      } else {
        (@cmd.none(), model)
      }
    GoTitle =>
      (
        @cmd.none(),
        { ..model, screen: Top, is_typing_active: false, is_input_ready: true },
      )
    GoResult => (@cmd.none(), { ..model, screen: Result })
    SelectTime(value) =>
      (
        @cmd.none(),
        { ..model, time_seconds: value, timer: create_timer(value * 1000) },
      )
    SelectCategory(value) => (@cmd.none(), { ..model, category: value })
    UpdateFilter(value) => (@cmd.none(), { ..model, filter: value })
    UpdateTyping(value) => (@cmd.none(), apply_typing_input(model, value))
    StartTyping =>
      if model.screen == Top {
        (@cmd.none(), { ..model, is_input_ready: true })
      } else {
        let typing_session = match model.typing_session {
          Some(_) => model.typing_session
          None => init_session_from_queue(model.word_queue)
        }
        (
          @cmd.none(),
          {
            ..model,
            is_typing_active: true,
            is_input_ready: true,
            typing_input: "",
            typing_session,
          },
        )
      }
    StopTyping => (@cmd.none(), { ..model, is_typing_active: false })
    Tick =>
      if model.screen != Playing {
        (@cmd.none(), model)
      } else {
        let next_timer = tick_timer(model.timer, 1000)
        let next_model = {
          ..model,
          timer: next_timer,
          is_typing_active: if is_finished(next_timer) {
            false
          } else {
            model.is_typing_active
          },
        }
        if !is_finished(next_timer) {
          (schedule_tick(1000), next_model)
        } else {
          (
            @cmd.none(),
            { ..next_model, screen: Result, is_typing_active: false },
          )
        }
      }
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
fn apply_typing_input(model : Model, value : String) -> Model {
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
fn start_session(model : Model) -> (@cmd.Cmd[Msg], Model) {
  let (queue, next_index) = build_word_queue(model.next_word_index, 10) catch {
    _ => ([], model.next_word_index)
  }
  let typing_session = init_session_from_queue(queue)
  let timer = start_timer(create_timer(model.time_seconds * 1000))
  (
    schedule_tick(1000),
    {
      ..model,
      screen: Playing,
      timer,
      is_typing_active: true,
      is_input_ready: true,
      typing_input: "",
      word_queue: queue,
      next_word_index: next_index,
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
fn advance_to_next_word(model : Model) -> Model {
  let mut completed_display = model.completed_display
  let mut completed_roman = model.completed_roman
  if model.word_queue.length() > 1 {
    completed_display += " "
    completed_roman += " "
  }
  let (queue, next_index) = advance_word_queue(
    model.word_queue,
    model.next_word_index,
  )
  let typing_session = init_session_from_queue(queue)
  {
    ..model,
    word_queue: queue,
    next_word_index: next_index,
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
