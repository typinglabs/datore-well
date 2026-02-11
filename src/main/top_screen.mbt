///|
fn time_button(model : Model, value : Int) -> @html.Html[Msg] {
  let base = "cursor-pointer bg-ink/5 px-2 py-0.5 text-xs"
  let class_name = if model.time_seconds == value {
    base + " font-semibold"
  } else {
    base + " opacity-60"
  }
  button(class=class_name, click=SelectTime(value), [text("\{value}秒")])
}

///|
fn category_button(
  model : Model,
  value : Category,
  label : String,
) -> @html.Html[Msg] {
  let base = "cursor-pointer bg-ink/5 px-2 py-0.5 text-xs"
  let class_name = if model.category == value {
    base + " font-semibold"
  } else {
    base + " opacity-60"
  }
  button(class=class_name, click=SelectCategory(value), [text(label)])
}

///|
fn top_preview_state() -> (String, String, String, String) {
  // ここでワード生成するとダメだと思う
  let (queue, _) = build_word_queue(0, 10) catch { _ => ([], 0) }
  let kana_right = queue.map(item => item.display).join(" ")
  let roman_right = queue.map(item => item.roman).join(" ")
  ("", kana_right, "", roman_right)
}

///|
fn top_screen(model : Model) -> @html.Html[Msg] {
  let (kana_left, kana_right, roman_left, roman_right) = top_preview_state()
  let cursor_class = if model.is_input_ready {
    "h-6 w-0.5 self-center justify-self-center bg-ink"
  } else {
    "h-6 w-0.5 self-center justify-self-center bg-ink opacity-0"
  }
  let settings_class = if model.is_typing_active {
    "relative z-10 grid grid-cols-1 items-start gap-6 opacity-0 pointer-events-none md:grid-cols-3"
  } else {
    "relative z-10 grid grid-cols-1 items-start gap-6 md:grid-cols-3"
  }
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="pt-2 relative", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        button(
          class="cursor-pointer bg-transparent text-lg font-semibold uppercase tracking-widest",
          click=GoTitle,
          [text("打トレ単語練習")],
        ),
      ]),
      div(class="mt-6 border-t border-ink/25", []),
      div(class="relative mt-6", [
        div(class=settings_class, [
          div([
            p(class="text-xs uppercase tracking-widest", [text("時間")]),
            div(class="mt-3 flex flex-wrap gap-2", [
              time_button(model, 15),
              time_button(model, 30),
              time_button(model, 60),
              time_button(model, 120),
            ]),
          ]),
          div([
            p(class="text-xs uppercase tracking-widest", [
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
            p(class="text-xs uppercase tracking-widest", [
              text("フィルター"),
            ]),
            input(
              class="mt-3 w-full border border-ink/25 px-3 py-2.5 text-sm",
              placeholder="ローマ字 / かな で絞り込み",
              value=model.filter,
              input=x => UpdateFilter(x),
            ),
          ]),
        ]),
        div(
          class="pointer-events-none fixed left-1/2 top-1/2 flex w-full max-w-5xl -translate-x-1/2 -translate-y-1/2 -mt-6 items-center justify-center px-6",
          [
            div(
              class="relative w-full min-h-11 cursor-text overflow-hidden border-0 py-3 pointer-events-auto",
              [
                input(
                  id="typing-input",
                  class="absolute inset-0 opacity-0 z-10",
                  value=model.typing_input,
                  input=x => StartFromInput(x),
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
              ],
            ),
          ],
        ),
      ]),
    ]),
  ])
}
