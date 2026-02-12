///|
fn time_button(form : Form, value : Int) -> @html.Html[Msg] {
  let base = "cursor-pointer bg-ink/5 px-2 py-0.5 text-xs"
  let class_name = if form.time_seconds == value {
    base + " font-semibold"
  } else {
    base + " opacity-60"
  }
  button(class=class_name, click=SelectTime(value), [text("\{value}秒")])
}

///|
fn category_button(
  form : Form,
  value : Category,
  label : String,
) -> @html.Html[Msg] {
  let base = "cursor-pointer bg-ink/5 px-2 py-0.5 text-xs"
  let class_name = if form.category == value {
    base + " font-semibold"
  } else {
    base + " opacity-60"
  }
  button(class=class_name, click=SelectCategory(value), [text(label)])
}

///|
fn top_preview_state(
  words : Array[WordItem],
) -> (String, String, String, String) {
  // ここでワード生成するとダメだと思う
  if words.length() == 0 {
    return ("", "", "", "")
  }
  let queue = build_word_queue(words, 10)
  let kana_right = queue.map(item => item.display).join(" ")
  let roman_right = queue.map(item => item.roman).join(" ")
  ("", kana_right, "", roman_right)
}

///|
fn top_screen(model : TopModel, form : Form) -> @html.Html[Msg] {
  let (kana_left, kana_right, roman_left, roman_right) = top_preview_state(
    model.filtered_words,
  )
  let cursor_class = if model.is_input_ready {
    "h-6 w-0.5 self-center justify-self-center bg-ink"
  } else {
    "h-6 w-0.5 self-center justify-self-center bg-ink opacity-0"
  }
  let empty_message = if model.filtered_words.length() == 0 {
    [
      div(
        class="pointer-events-none fixed left-1/2 top-1/2 flex w-full max-w-5xl -translate-x-1/2 -translate-y-1/2 -mt-6 items-center justify-center px-6",
        [
          div(
            class="relative w-full min-h-11 overflow-hidden border-0 py-3 text-center text-xl tracking-widest text-ink/60",
            [text("結果が見つかりませんでした")],
          ),
        ],
      ),
    ]
  } else {
    []
  }
  let word_area = div(
    [
      word_display(
        model.typing_input,
        x => StartFromInput(x),
        cursor_class,
        "relative w-full min-h-11 cursor-text overflow-hidden border-0 py-3",
        kana_left,
        kana_right,
        roman_left,
        roman_right,
      ),
      ..empty_message,
    ],
  )
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="pt-2 relative", [
      app_header(None),
      div(class="mt-6 border-t border-ink/25", []),
      div(class="relative mt-6", [
        div(
          class="relative z-10 grid grid-cols-1 items-start gap-6 md:grid-cols-3",
          [
            div([
              p(class="text-xs uppercase tracking-widest", [text("時間")]),
              div(class="mt-3 flex flex-wrap gap-2", [
                time_button(form, 15),
                time_button(form, 30),
                time_button(form, 60),
                time_button(form, 120),
              ]),
            ]),
            div([
              p(class="text-xs uppercase tracking-widest", [
                text("カテゴリー"),
              ]),
              div(class="mt-3 flex flex-wrap gap-2", [
                category_button(form, All, "全て"),
                category_button(form, Kanji, "漢字"),
                category_button(form, Katakana, "カタカナ"),
                category_button(form, Hiragana, "ひらがな"),
              ]),
            ]),
            label(class="block", [
              p(class="text-xs uppercase tracking-widest", [
                text("フィルター"),
              ]),
              input(
                class="mt-3 w-full border border-ink/25 px-3 py-2.5 text-sm",
                placeholder="ひらがな で絞り込み",
                value=form.filter,
                input=x => UpdateFilter(x),
              ),
            ]),
          ],
        ),
        word_area,
      ]),
    ]),
  ])
}
