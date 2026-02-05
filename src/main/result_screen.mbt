///|
fn result_screen(model : Model) -> @html.Html[Msg] {
  let score = calc_score_from(model.hits, model.miss, model.timer.elapsed_ms)
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="tui-frame", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        button(class="tui-brand", click=GoTitle, [
          text("打トレ単語練習"),
        ]),
        button(class="tui-button", click=GoTitle, [text("トップへ戻る")]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4", [
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("打鍵数")]),
          p(class="mt-3 text-2xl", [text(score.total_keys.to_string())]),
        ]),
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("ミス数")]),
          p(class="mt-3 text-2xl", [text(model.miss.to_string())]),
        ]),
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("KPM")]),
          p(class="mt-3 text-2xl", [text(score.cpm.to_string())]),
        ]),
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("正確率")]),
          p(class="mt-3 text-2xl", [text("\{score.accuracy_percent}%")]),
        ]),
      ]),
    ]),
  ])
}
