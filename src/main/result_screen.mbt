///|
fn result_screen(model : Model) -> @html.Html[Msg] {
  let score = calc_score_from(model.hits, model.miss, model.timer.elapsed_ms)
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="pt-2", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        button(
          class="cursor-pointer bg-transparent text-lg font-semibold uppercase tracking-widest",
          click=GoTitle,
          [text("打トレ単語練習")],
        ),
        button(
          class="cursor-pointer bg-transparent border-b border-ink px-0.5 py-1 text-sm uppercase tracking-widest",
          click=GoTitle,
          [text("トップへ戻る")],
        ),
      ]),
      div(class="mt-6 border-t border-ink/25", []),
      div(class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4", [
        div(class="bg-ink/5 p-4 text-sm", [
          p(class="text-xs uppercase tracking-widest", [text("打鍵数")]),
          p(class="mt-3 text-2xl", [text(score.total_keys.to_string())]),
        ]),
        div(class="bg-ink/5 p-4 text-sm", [
          p(class="text-xs uppercase tracking-widest", [text("ミス数")]),
          p(class="mt-3 text-2xl", [text(model.miss.to_string())]),
        ]),
        div(class="bg-ink/5 p-4 text-sm", [
          p(class="text-xs uppercase tracking-widest", [text("KPM")]),
          p(class="mt-3 text-2xl", [text(score.cpm.to_string())]),
        ]),
        div(class="bg-ink/5 p-4 text-sm", [
          p(class="text-xs uppercase tracking-widest", [text("正確率")]),
          p(class="mt-3 text-2xl", [text("\{score.accuracy_percent}%")]),
        ]),
      ]),
    ]),
  ])
}
