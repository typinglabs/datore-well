///|
struct WordItem {
  kana : String
  roman : String
}

///|
fn hiragana_words() -> Array[String] {
  [
    "あいうえお",
    "かきくけこ",
    "きゅう",
    "しゃ",
    "つ",
  ]
}

///|
fn init_hiragana_items() -> Array[WordItem] {
  let items : Array[WordItem] = []
  for word in hiragana_words() {
    let result = try {
      let (roman_state, _apply_key) = create_roman_engine(word)
      Some({ kana: word, roman: roman_state.remaining_roman })
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
let hiragana_items : Array[WordItem] = init_hiragana_items()

///|
fn build_word_queue(
  start_index : Int,
  size : Int,
) -> (Array[WordItem], Int) raise Error {
  let words = hiragana_items
  if words.length() == 0 {
    abort("hiragana_words is empty")
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
  let words = hiragana_items
  if queue.length() == 0 {
    return try {
      build_word_queue(next_index, 10)
    } catch {
      _ => ([], next_index)
    }
  }
  let next_queue = queue[1:queue.length()].to_array()
  let word = words[next_index % words.length()]
  next_queue.push(word)
  (next_queue, (next_index + 1) % words.length())
}

///|
fn make_word_item(word : String) -> WordItem raise Error {
  let (roman_state, _apply_key) = create_roman_engine(word)
  { kana: word, roman: roman_state.remaining_roman }
}
