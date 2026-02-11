///|
fn format_timer(timer : Timer) -> String {
  let total_seconds = remaining_ms(timer) / 1000
  let minutes = total_seconds / 60
  let seconds = total_seconds % 60
  [minutes.to_string().pad_start(2, '0'), seconds.to_string().pad_start(2, '0')].join(
    ":",
  )
}

///|
test "format_timer" {
  let timer = @typing.create_timer(60 * 1000)
  assert_eq(format_timer(timer), "01:00")
  let timer = @typing.create_timer(55 * 1000)
  assert_eq(format_timer(timer), "00:55")
  let timer = @typing.create_timer(8 * 1000)
  assert_eq(format_timer(timer), "00:08")
}

///|
fn typing_state(model : Model) -> (String, String, String, String) {
  // SessionがNoneになるのは、主にワードを打ち終わっている場合
  let (typed_display, remaining_display, typed_roman, remaining_roman) = match
    model.typing_session {
    None => ("", "", "", "")
    Some(session) =>
      (
        try! session.word.display[:][0:session.kanji_state.typed_kanji_len].to_string(),
        try! session.word.display[:][session.kanji_state.typed_kanji_len:].to_string(),
        session.kanji_state.typed_romaji,
        session.kanji_state.remaining_romaji,
      )
  }
  let kana_left = model.completed_display + typed_display
  let roman_left = model.completed_roman + typed_roman
  let kana_right = [
    remaining_display,
    ..model.word_queue[1:].map(word => word.display),
  ].join(" ")
  let roman_right = [
    remaining_roman,
    ..model.word_queue[1:].map(word => word.roman),
  ].join(" ")
  (kana_left, kana_right, roman_left, roman_right)
}

///|
fn playing_screen(model : Model) -> @html.Html[Msg] {
  let (kana_left, kana_right, roman_left, roman_right) = typing_state(model)
  let cursor_class = if model.is_typing_active {
    "cursor"
  } else {
    "cursor hidden"
  }
  let zone_class = if model.is_typing_active {
    "px-1 py-3 text-lg leading-relaxed input-zone relative is-active"
  } else {
    "px-1 py-3 text-lg leading-relaxed input-zone relative"
  }
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="tui-frame", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        button(class="tui-brand", click=GoTitle, [text("打トレ単語練習")]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class="typing-stage mt-6", [
        div(class="typing-meta", [
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("時間")]),
            p(class="mt-2 text-lg", [text(format_timer(model.timer))]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("正解")]),
            p(class="mt-2 text-lg", [text(model.hits.to_string())]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("ミス")]),
            p(class="mt-2 text-lg", [text(model.miss.to_string())]),
          ]),
        ]),
        div(class="typing-center", [
          div(class=zone_class + " typing-zone", click=StartTyping, [
            input(
              id="typing-input",
              class="absolute inset-0 opacity-0 z-10",
              value=model.typing_input,
              input=x => UpdateTyping(x),
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
      ]),
    ]),
  ])
}
