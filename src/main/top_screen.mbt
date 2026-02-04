///|
fn top_screen(model : Model) -> @html.Html[Msg] {
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="tui-frame", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        div([
          p(class="text-xs uppercase tracking-[0.2em]", [text("Title")]),
          h2(class="mt-2 text-2xl font-semibold", [text("Session Setup")]),
        ]),
        button(class="tui-button", click=Start, [text("Start Typing")]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class="mt-6 grid gap-6 lg:grid-cols-[1.2fr_1fr]", [
        div(class="space-y-5", [
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("Time")]),
            div(class="mt-3 flex flex-wrap gap-2", [
              time_button(model, 15),
              time_button(model, 30),
              time_button(model, 60),
              time_button(model, 120),
            ]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("Category")]),
            div(class="mt-3 flex flex-wrap gap-2", [
              category_button(model, All, "All"),
              category_button(model, Kanji, "Kanji"),
              category_button(model, Katakana, "Katakana"),
              category_button(model, Hiragana, "Hiragana"),
            ]),
          ]),
          label(class="block", [
            p(class="text-xs uppercase tracking-[0.2em]", [text("Filter")]),
            input(
              class="tui-input mt-3 w-full",
              placeholder="Type roman or kana to filter",
              value=model.filter,
              input=UpdateFilter(_),
            ),
          ]),
        ]),
        div(class="tui-panel", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("Preview")]),
          div(class="mt-4 flex flex-wrap gap-2 text-sm", [
            span(class="tui-chip", [text("生活")]),
            span(class="tui-chip", [text("存在")]),
            span(class="tui-chip", [text("完走")]),
            span(class="tui-chip", [text("調子")]),
            span(class="tui-chip", [text("時間")]),
            span(class="tui-chip", [text("相談")]),
            span(class="tui-chip", [text("ワクワク")]),
            span(class="tui-chip", [text("お互い")]),
          ]),
          p(class="mt-6 text-sm", [text("Start typing to begin the session.")]),
        ]),
      ]),
    ]),
  ])
}

///|
fn time_button(model : Model, value : Int) -> @html.Html[Msg] {
  let class_name = if model.time_seconds == value {
    "tui-chip font-semibold"
  } else {
    "tui-chip opacity-60"
  }
  button(class=class_name, click=SelectTime(value), [text("\{value}s")])
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
