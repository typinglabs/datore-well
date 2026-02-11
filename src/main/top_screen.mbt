///|
fn time_button(model : Model, value : Int) -> @html.Html[Msg] {
  let class_name = if model.time_seconds == value {
    "tui-chip font-semibold"
  } else {
    "tui-chip opacity-60"
  }
  button(class=class_name, click=SelectTime(value), [text("\{value}秒")])
}

///|
fn category_button(
  model : Model,
  value : Category,
  label : String,
) -> @html.Html[Msg] {
  let class_name = if model.category == value {
    "tui-chip font-semibold"
  } else {
    "tui-chip opacity-60"
  }
  button(class=class_name, click=SelectCategory(value), [text(label)])
}

///|
fn top_preview_state() -> (String, String, String, String) {
  // ここでワード生成するとダメだと思う
  let (queue, _) = build_word_queue(0, 10) catch { _ => ([], 0) }
  let kana_right = queue.map(item => item.display).join(" ")
  let roman_right = queue.map(item => item.roman).join(" ")
  ("", kana_right, "", roman_right)
}

///|
fn top_screen(model : Model) -> @html.Html[Msg] {
  let (kana_left, kana_right, roman_left, roman_right) = top_preview_state()
  let cursor_class = if model.is_input_ready {
    "cursor"
  } else {
    "cursor hidden"
  }
  let settings_class = if model.is_typing_active {
    "top-settings settings-row is-fading"
  } else {
    "top-settings settings-row"
  }
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="tui-frame top-screen", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        button(class="tui-brand", click=GoTitle, [text("打トレ単語練習")]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class="typing-stage mt-6", [
        div(class=settings_class, [
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("時間")]),
            div(class="mt-3 flex flex-wrap gap-2", [
              time_button(model, 15),
              time_button(model, 30),
              time_button(model, 60),
              time_button(model, 120),
            ]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [
              text("カテゴリー"),
            ]),
            div(class="mt-3 flex flex-wrap gap-2", [
              category_button(model, All, "全て"),
              category_button(model, Kanji, "漢字"),
              category_button(model, Katakana, "カタカナ"),
              category_button(model, Hiragana, "ひらがな"),
            ]),
          ]),
          label(class="block", [
            p(class="text-xs uppercase tracking-[0.2em]", [
              text("フィルター"),
            ]),
            input(
              class="tui-input mt-3 w-full",
              placeholder="ローマ字 / かな で絞り込み",
              value=model.filter,
              input=x => UpdateFilter(x),
            ),
          ]),
        ]),
        div(class="typing-center", [
          div(class="input-zone typing-zone relative", click=StartTyping, [
            input(
              id="typing-input",
              class="absolute inset-0 opacity-0 z-10",
              value=model.typing_input,
              input=x => StartFromInput(x),
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
