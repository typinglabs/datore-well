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
fn build_word_queue(size : Int) -> Array[WordItem] {
  let words = datore_items
  if words.length() == 0 {
    abort("datore_words is empty")
  }
  let queue : Array[WordItem] = []
  let mut index = 0
  for _i = 0; _i < size; _i = _i + 1 {
    queue.push(words[index])
    index = (index + 1) % words.length()
  }
  queue
}

///|
fn advance_word_queue(queue : Array[WordItem]) -> Array[WordItem] {
  let words = datore_items
  if queue.length() == 0 {
    return build_word_queue(10)
  }
  let next_queue = queue[1:queue.length()].to_array()
  let last_word = queue[queue.length() - 1]
  let next_index = match find_word_index(words, last_word) {
    None => 0
    Some(index) => (index + 1) % words.length()
  }
  let word = words[next_index]
  next_queue.push(word)
  next_queue
}

///|
fn find_word_index(words : Array[WordItem], target : WordItem) -> Int? {
  for i = 0; i < words.length(); i = i + 1 {
    let word = words[i]
    if word.annotated == target.annotated &&
      word.display == target.display &&
      word.roman == target.roman {
      return Some(i)
    }
  }
  None
}
