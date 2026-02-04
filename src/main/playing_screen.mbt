///|
fn playing_screen(_model : Model) -> @html.Html[Msg] {
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
            p(class="mt-2 text-lg", [text("00:48")]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("Hits")]),
            p(class="mt-2 text-lg", [text("134")]),
          ]),
          div([
            p(class="text-xs uppercase tracking-[0.2em]", [text("Miss")]),
            p(class="mt-2 text-lg", [text("2")]),
          ]),
        ]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class="mt-6 px-1 py-3 text-lg leading-relaxed", [
        span(class="opacity-50", [text("生活 存在")]),
        span(class="mx-2 tui-highlight text-sm", [text("彼")]),
        text("完走 可能性 調子 時間 正当 手段 選択 資料"),
      ]),
      div(class="mt-6 grid gap-4 sm:grid-cols-[1fr_auto]", [
        div(class="tui-input", [
          text("seikatu sonzai kare kanousei tyousi jikan"),
        ]),
        button(class="tui-button", [text("Pause")]),
      ]),
    ]),
  ])
}
