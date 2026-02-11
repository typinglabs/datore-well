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
  ].join(" ")
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
    "h-6 w-0.5 self-center justify-self-center bg-ink"
  } else {
    "h-6 w-0.5 self-center justify-self-center bg-ink opacity-0"
  }
  let zone_class = if model.is_typing_active {
    "relative w-full min-h-11 cursor-text overflow-hidden border-0 py-3 outline-none"
  } else {
    "relative w-full min-h-11 cursor-text overflow-hidden border-0 py-3"
  }
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="pt-2", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        button(
          class="cursor-pointer bg-transparent text-lg font-semibold uppercase tracking-widest",
          click=GoTitle,
          [text("打トレ単語練習")],
        ),
      ]),
      div(class="mt-6 border-t border-ink/25", []),
      div(class="relative mt-6", [
        div(class="absolute right-0 top-0 z-[1] flex items-center gap-6", [
          div([
            p(class="text-xs uppercase tracking-widest", [text("時間")]),
            p(class="mt-2 text-lg", [text(format_timer(model.timer))]),
          ]),
          div([
            p(class="text-xs uppercase tracking-widest", [text("正解")]),
            p(class="mt-2 text-lg", [text(model.hits.to_string())]),
          ]),
          div([
            p(class="text-xs uppercase tracking-widest", [text("ミス")]),
            p(class="mt-2 text-lg", [text(model.miss.to_string())]),
          ]),
        ]),
        div(
          class="pointer-events-none fixed left-1/2 top-1/2 flex w-full max-w-5xl -translate-x-1/2 -translate-y-1/2 -mt-6 items-center justify-center px-6",
          [
            div(class=zone_class + " pointer-events-auto", [
              input(
                id="typing-input",
                class="absolute inset-0 opacity-0 z-10",
                value=model.typing_input,
                input=x => UpdateTyping(x),
              ),
              div(
                class="pointer-events-none grid w-full min-w-0 gap-1.5 text-2xl leading-loose",
                [
                  div(class="w-full min-w-0", [
                    div(
                      class="flex w-full min-w-0 items-baseline whitespace-pre text-3xl tracking-widest",
                      [
                        div(
                          class="flex min-w-0 flex-1 justify-end overflow-hidden whitespace-nowrap text-ink",
                          [span(class="whitespace-pre", [text(kana_left)])],
                        ),
                        span(class=cursor_class + " shrink-0", []),
                        span(
                          class="block min-w-0 flex-1 overflow-hidden whitespace-pre text-left text-ink/50 text-clip",
                          [text(kana_right)],
                        ),
                      ],
                    ),
                  ]),
                  div(class="w-full min-w-0", [
                    div(
                      class="flex w-full min-w-0 items-baseline whitespace-pre font-mono text-xl",
                      [
                        div(
                          class="flex min-w-0 flex-1 justify-end overflow-hidden whitespace-nowrap text-ink",
                          [span(class="whitespace-pre", [text(roman_left)])],
                        ),
                        span(class=cursor_class + " shrink-0", []),
                        span(
                          class="block min-w-0 flex-1 overflow-hidden whitespace-pre text-left text-ink/50 text-clip",
                          [text(roman_right)],
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ]),
          ],
        ),
      ]),
    ]),
  ])
}
