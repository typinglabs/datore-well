///|
fn playing_screen(model : Model) -> @html.Html[Msg] {
  let (kana_left, kana_right, roman_left, roman_right) = typing_state(model)
  let cursor_class = if model.is_typing_active {
    "cursor"
  } else {
    "cursor hidden"
  }
  let zone_class = if model.is_typing_active {
    "mt-6 px-1 py-3 text-lg leading-relaxed input-zone relative is-active"
  } else {
    "mt-6 px-1 py-3 text-lg leading-relaxed input-zone relative"
  }
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="tui-frame", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        div([
          p(class="text-xs uppercase tracking-[0.2em]", [text("Game")]),
          h2(class="mt-2 text-2xl font-semibold", [text("Typing Flow")]),
        ]),
        div(class="flex items-center gap-6 text-sm", [
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("Time")]),
            p(class="mt-2 text-lg", [text(format_timer(model.timer))]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("Hits")]),
            p(class="mt-2 text-lg", [text(model.hits.to_string())]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("Miss")]),
            p(class="mt-2 text-lg", [text(model.miss.to_string())]),
          ]),
        ]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class=zone_class, click=StartTyping, [
        input(
          id="typing-input",
          class="absolute inset-0 opacity-0 z-10",
          value=model.typing_input,
          input=UpdateTyping(_),
        ),
        div(class="baseline pointer-events-none", [
          div(class="row", [
            div(class="kana", [
              div(class="left left-wrap", [
                span(class="left-text", [text(kana_left)]),
              ]),
              span(class=cursor_class, []),
              span(class="right", [text(kana_right)]),
            ]),
          ]),
          div(class="row", [
            div(class="roman", [
              div(class="left left-wrap", [
                span(class="left-text", [text(roman_left)]),
              ]),
              span(class=cursor_class, []),
              span(class="right", [text(roman_right)]),
            ]),
          ]),
        ]),
      ]),
    ]),
  ])
}

///|
fn format_timer(timer : Timer) -> String {
  let total_seconds = remaining_ms(timer) / 1000
  let minutes = total_seconds / 60
  let seconds = total_seconds % 60
  let minute_text = if minutes < 10 {
    "0" + minutes.to_string()
  } else {
    minutes.to_string()
  }
  let second_text = if seconds < 10 {
    "0" + seconds.to_string()
  } else {
    seconds.to_string()
  }
  minute_text + ":" + second_text
}

///|
fn typing_state(model : Model) -> (String, String, String, String) {
  let (typed_kana, remaining_kana, typed_roman, remaining_roman) =
    match model.typing_session {
      None => ("", "", "", "")
      Some(session) =>
        (
          session.roman_state.typed_kana,
          session.roman_state.remaining_kana,
          session.roman_state.typed_roman,
          session.roman_state.remaining_roman,
        )
    }
  let kana_left = model.completed_kana + typed_kana
  let roman_left = model.completed_roman + typed_roman
  let (kana_tail, roman_tail) = future_tail(model.word_queue)
  let kana_right = join_right(remaining_kana, kana_tail)
  let roman_right = join_right(remaining_roman, roman_tail)
  (kana_left, kana_right, roman_left, roman_right)
}

///|
fn future_tail(queue : Array[WordItem]) -> (String, String) {
  if queue.length() <= 1 {
    return ("", "")
  }
  let mut kana = ""
  let mut roman = ""
  let mut first = true
  for item in queue[1:queue.length()] {
    if first {
      first = false
    } else {
      kana += " "
      roman += " "
    }
    kana += item.kana
    roman += item.roman
  }
  (kana, roman)
}

///|
fn join_right(current : String, tail : String) -> String {
  if current == "" {
    if tail == "" { "" } else { " " + tail }
  } else if tail == "" {
    current
  } else {
    current + " " + tail
  }
}

///|
