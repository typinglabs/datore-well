///|
fn result_screen(_model : Model) -> @html.Html[Msg] {
  div(class="mx-auto flex w-full max-w-5xl flex-col gap-8", [
    section(class="tui-frame", [
      div(class="flex flex-wrap items-center justify-between gap-4", [
        div([
          p(class="text-xs uppercase tracking-[0.2em]", [text("Result")]),
          h2(class="mt-2 text-2xl font-semibold", [text("Session Summary")]),
        ]),
        div(class="flex gap-2", [
          button(class="tui-button", [text("Retry")]),
          button(class="tui-button", [text("Title")]),
        ]),
      ]),
      div(class="tui-rule mt-6", []),
      div(class="mt-6 grid gap-4 sm:grid-cols-3", [
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("Accuracy")]),
          p(class="mt-3 text-2xl", [text("92%")]),
        ]),
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("WPM")]),
          p(class="mt-3 text-2xl", [text("58")]),
        ]),
        div(class="tui-panel text-sm", [
          p(class="text-xs uppercase tracking-[0.2em]", [text("CPM")]),
          p(class="mt-3 text-2xl", [text("290")]),
        ]),
      ]),
      div(class="mt-6 px-1 py-3 text-xs opacity-70", [
        text("Graph preview goes here."),
      ]),
    ]),
  ])
}
