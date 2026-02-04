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
fn build_word_queue(
  start_index : Int,
  size : Int,
) -> (Array[WordItem], Int) raise Error {
  let words = hiragana_words()
  if words.length() == 0 {
    abort("hiragana_words is empty")
  }
  let queue : Array[WordItem] = []
  let mut index = start_index % words.length()
  for _i = 0; _i < size; _i = _i + 1 {
    queue.push(make_word_item(words[index]))
    index = (index + 1) % words.length()
  }
  (queue, index)
}

///|
fn advance_word_queue(
  queue : Array[WordItem],
  next_index : Int,
) -> (Array[WordItem], Int) {
  let words = hiragana_words()
  if queue.length() == 0 {
    return try {
      build_word_queue(next_index, 10)
    } catch {
      _ => ([], next_index)
    }
  }
  let next_queue = queue[1:queue.length()].to_array()
  let word = words[next_index % words.length()]
  let result = try {
    next_queue.push(make_word_item(word))
    (next_queue, (next_index + 1) % words.length())
  } catch {
    _ => (next_queue, next_index)
  }
  result
}

///|
fn make_word_item(word : String) -> WordItem raise Error {
  let (roman_state, _apply_key) = create_roman_engine(word)
  { kana: word, roman: roman_state.remaining_roman }
}
