///|
fn app_header(extra : @html.Html[Msg]?) -> @html.Html[Msg] {
  let items : Array[@html.Html[Msg]] = []
  items.push(
    button(
      class="cursor-pointer bg-transparent text-lg font-semibold uppercase tracking-widest",
      click=GoTitle,
      [text("打トレ単語練習")],
    ),
  )
  match extra {
    None => ()
    Some(node) => items.push(node)
  }
  div(class="flex flex-wrap items-center justify-between gap-4", items)
}

///|
fn word_display(
  typing_input : String,
  input_msg : (String) -> Msg,
  cursor_class : String,
  zone_class : String,
  kana_left : String,
  kana_right : String,
  roman_left : String,
  roman_right : String,
) -> @html.Html[Msg] {
  div(
    class="pointer-events-none fixed left-1/2 top-1/2 flex w-full max-w-5xl -translate-x-1/2 -translate-y-1/2 -mt-6 items-center justify-center px-6",
    [
      div(class=zone_class + " pointer-events-auto", [
        input(
          id="typing-input",
          class="absolute inset-0 opacity-0 z-10",
          value=typing_input,
          input=x => input_msg(x),
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
      ]),
    ],
  )
}
