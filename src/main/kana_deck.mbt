///|
struct WordItem {
  annotated : String
  display : String
  roman : String
}

///|
fn init_datore_items() -> Array[WordItem] {
  let items : Array[WordItem] = []
  for word in @typing.datore_words() {
    let result = try {
      let (kanji_state, _apply_key) = @romaji_typing.create_kanji_engine(
        word.text,
      )
      Some({
        annotated: word.text,
        display: kanji_state.display,
        roman: kanji_state.remaining_romaji,
      })
    } catch {
      _ => None
    }
    match result {
      Some(item) => items.push(item)
      None => ()
    }
  }
  items
}

///|
let datore_items : Array[WordItem] = init_datore_items()

///|
fn build_word_queue(
  start_index : Int,
  size : Int,
) -> (Array[WordItem], Int) raise Error {
  let words = datore_items
  if words.length() == 0 {
    abort("datore_words is empty")
  }
  let queue : Array[WordItem] = []
  let mut index = start_index % words.length()
  for _i = 0; _i < size; _i = _i + 1 {
    queue.push(words[index])
    index = (index + 1) % words.length()
  }
  (queue, index)
}

///|
fn advance_word_queue(
  queue : Array[WordItem],
  next_index : Int,
) -> (Array[WordItem], Int) {
  let words = datore_items
  if queue.length() == 0 {
    return build_word_queue(next_index, 10) catch { _ => ([], next_index) }
  }
  let next_queue = queue[1:queue.length()].to_array()
  let word = words[next_index % words.length()]
  next_queue.push(word)
  (next_queue, (next_index + 1) % words.length())
}

///|
fn make_word_item(word : @typing.Word) -> WordItem raise Error {
  let (kanji_state, _apply_key) = @romaji_typing.create_kanji_engine(word.text)
  {
    annotated: word.text,
    display: kanji_state.display,
    roman: kanji_state.remaining_romaji,
  }
}
