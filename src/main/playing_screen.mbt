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
  let timer = @util.create_timer(60 * 1000)
  assert_eq(format_timer(timer), "01:00")
  let timer = @util.create_timer(55 * 1000)
  assert_eq(format_timer(timer), "00:55")
  let timer = @util.create_timer(8 * 1000)
  assert_eq(format_timer(timer), "00:08")
}

///|
fn typing_state(model : TypingModel) -> (String, String, String, String) {
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
  let queue = model.word_queue.to_array()
  let kana_right = [remaining_display, ..queue[1:].map(word => word.display)].join(" ")
  let roman_right = [remaining_roman, ..queue[1:].map(word => word.roman)].join(" ")
  (kana_left, kana_right, roman_left, roman_right)
}

///|
fn playing_screen(model : TypingModel) -> @html.Html[Msg] {
  let (kana_left, kana_right, roman_left, roman_right) = typing_state(model)
  let cursor_class = if model.is_typing_active {
    "h-7 w-0.5 self-center justify-self-center bg-ink"
  } else {
    "h-7 w-0.5 self-center justify-self-center bg-ink opacity-0"
  }
  let zone_class = if model.is_typing_active {
    "relative w-full min-h-11 cursor-text overflow-hidden border-0 py-3 outline-none"
  } else {
    "relative w-full min-h-11 cursor-text overflow-hidden border-0 py-3"
  }
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="pt-2", [
      app_header(None),
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
        word_display(
          model.typing_input,
          x => UpdateTyping(x),
          cursor_class,
          zone_class,
          kana_left,
          kana_right,
          roman_left,
          roman_right,
          model.is_miss_active,
        ),
      ]),
    ]),
  ])
}
