///|
fn result_screen(model : Model) -> @html.Html[Msg] {
  let score = calc_score_from(model.hits, model.miss, model.timer.elapsed_ms)
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="tui-frame", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        div([
          p(class="text-xs uppercase tracking-[0.2em]", [text("Result")]),
          h2(class="mt-2 text-2xl font-semibold", [text("Session Summary")]),
        ]),
        div(class="flex gap-2", [
          button(class="tui-button", click=Start, [text("Retry")]),
          button(class="tui-button", click=GoTitle, [text("Title")]),
        ]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class="mt-6 grid gap-4 sm:grid-cols-3", [
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("Accuracy")]),
          p(class="mt-3 text-2xl", [text("\{score.accuracy_percent}%")]),
        ]),
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("WPM")]),
          p(class="mt-3 text-2xl", [text(score.wpm.to_string())]),
        ]),
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("CPM")]),
          p(class="mt-3 text-2xl", [text(score.cpm.to_string())]),
        ]),
      ]),
      div(class="mt-6 px-1 py-3 text-xs opacity-70", [
        text(
          "Hits \{model.hits} / Miss \{model.miss} / Total \{score.total_keys}",
        ),
      ]),
    ]),
  ])
}
