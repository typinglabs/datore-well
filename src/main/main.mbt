///|
enum Screen {
  Top
  Playing
  Result
}

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
  is_typing_active : Bool
  next_word_index : Int
  word_queue : Array[WordItem]
  typing_session : TypingSession?
  awaiting_space : Bool
  completed_kana : String
  completed_roman : String
}

///|
let model : Model = {
  screen: Top,
  time_seconds: 60,
  category: All,
  filter: "",
  typing_input: "",
  is_typing_active: false,
  next_word_index: 0,
  word_queue: [],
  typing_session: None,
  awaiting_space: false,
  completed_kana: "",
  completed_roman: "",
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
  StartTyping
  StopTyping
}

///|
fn update(msg : Msg, model : Model) -> (@tea.Cmd[Msg], Model) {
  match msg {
    Start => {
      let (queue, next_index) = try {
        build_word_queue(model.next_word_index, 10)
      } catch {
        _ => ([], model.next_word_index)
      }
      let typing_session = init_session_from_queue(queue)
      (
        @tea.none(),
        {
          ..model,
          screen: Playing,
          is_typing_active: false,
          typing_input: "",
          word_queue: queue,
          next_word_index: next_index,
          typing_session,
          awaiting_space: false,
          completed_kana: "",
          completed_roman: "",
        },
      )
    }
    GoTitle => (@tea.none(), { ..model, screen: Top })
    GoResult => (@tea.none(), { ..model, screen: Result })
    SelectTime(value) => (@tea.none(), { ..model, time_seconds: value })
    SelectCategory(value) => (@tea.none(), { ..model, category: value })
    UpdateFilter(value) => (@tea.none(), { ..model, filter: value })
    UpdateTyping(value) => (@tea.none(), apply_typing_input(model, value))
    StartTyping => {
      let typing_session = match model.typing_session {
        Some(_) => model.typing_session
        None => init_session_from_queue(model.word_queue)
      }
      (
        @tea.none(),
        {
          ..model,
          is_typing_active: true,
          typing_input: "",
          typing_session,
        },
      )
    }
    StopTyping => (@tea.none(), { ..model, is_typing_active: false })
  }
}

///|
struct TypingSession {
  word : WordItem
  roman_state : RomanState
  apply_key : ApplyKeyFn
}

///|
fn init_typing_session(word : WordItem) -> TypingSession? {
  try {
    let (roman_state, apply_key) = create_roman_engine(word.kana)
    Some({ word, roman_state, apply_key })
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
    Some(ch) => {
      if model.awaiting_space {
        if ch == ' ' {
          let next_model = advance_to_next_word(model)
          { ..next_model, typing_input: "" }
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
              let (next_state, result) = (session.apply_key)(
                session.roman_state,
                ch,
              )
              match result {
                WordCompleted => {
                  {
                    ..model,
                    typing_session: None,
                    awaiting_space: true,
                    completed_kana: model.completed_kana + session.word.kana,
                    completed_roman: model.completed_roman + session.word.roman,
                  }
                }
                WrongKey => model
                CorrectKey =>
                  {
                    ..model,
                    typing_session: Some({ ..session, roman_state: next_state }),
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
}

///|
fn advance_to_next_word(model : Model) -> Model {
  let mut completed_kana = model.completed_kana
  let mut completed_roman = model.completed_roman
  if model.word_queue.length() > 1 {
    completed_kana += " "
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
    completed_kana,
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
