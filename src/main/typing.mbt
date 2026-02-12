///|
fn last_char(value : String) -> Char? {
  match value[:] {
    [] => None
    [.., last] => Some(last)
  }
}

///|
struct TypingSession {
  word : WordItem
  kanji_state : @romaji_typing.KanjiState
  apply_key : @romaji_typing.ApplyKanjiKeyFn
}

///|
fn init_session_from_queue(queue : Array[WordItem]) -> TypingSession? {
  if queue.length() == 0 {
    None
  } else {
    let word = queue[0]
    try {
      let (kanji_state, apply_key) = @romaji_typing.create_kanji_engine(
        word.annotated,
      )
      Some({ word, kanji_state, apply_key })
    } catch {
      _ => None
    }
  }
}

///|
fn advance_to_next_word(model : TypingModel) -> TypingModel {
  let mut completed_display = model.completed_display
  let mut completed_roman = model.completed_roman
  if model.word_queue.length() > 1 {
    completed_display += " "
    completed_roman += " "
  }
  let queue = advance_word_queue(model.filtered_words, model.word_queue)
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
          {
            ..next_model,
            typing_input: "",
            hits: model.hits + 1,
            is_miss_active: false,
          }
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
                    is_miss_active: false,
                  }
                WrongKey =>
                  { ..model, miss: model.miss + 1, is_miss_active: true }
                CorrectKey =>
                  {
                    ..model,
                    typing_session: Some({ ..session, kanji_state: next_state }),
                    hits: model.hits + 1,
                    is_miss_active: false,
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
fn start_session(
  form : Form,
  filtered_words : Array[WordItem],
  first_key : String,
) -> (@cmd.Cmd[Msg], TypingModel) {
  let queue = build_word_queue(filtered_words, 10)
  let typing_session = init_session_from_queue(queue)
  let timer = start_timer(create_timer(form.time_seconds * 1000))
  let model : TypingModel = {
    timer,
    typing_input: "",
    is_typing_active: true,
    filtered_words,
    word_queue: queue,
    typing_session,
    awaiting_space: false,
    completed_display: "",
    completed_roman: "",
    hits: 0,
    miss: 0,
    is_miss_active: false,
  }
  let model = apply_typing_input(model, first_key)
  (schedule_tick(1000), model)
}
