///|
struct WordItem {
  annotated : String
  display : String
  roman : String
  kind : @util.WordKind
}

///|
fn init_all_items() -> Array[WordItem] {
  let items : Array[WordItem] = []
  for word in @util.datore_words() {
    let result = try {
      let (kanji_state, _apply_key) = @romaji_typing.create_kanji_engine(
        word.text,
      )
      Some({
        annotated: word.text,
        display: kanji_state.display,
        roman: kanji_state.remaining_romaji,
        kind: word.kind,
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
let all_items : Array[WordItem] = init_all_items()

///|
fn build_filtered_words_from_category(category : Category) -> Array[WordItem] {
  let result : Array[WordItem] = []
  for word in all_items {
    if is_word_allowed(category, word.kind) {
      result.push(word)
    }
  }
  result
}

///|
fn is_word_allowed(category : Category, kind : @util.WordKind) -> Bool {
  match (category, kind) {
    (All, _) => true
    (Kanji, @util.Kanji) => true
    (Katakana, @util.Katakana) => true
    (Hiragana, @util.Hiragana) => true
    (_, _) => false
  }
}

///|
fn shuffle_word_items(words : Array[WordItem], seed : Int) -> Array[WordItem] {
  let result = copy_word_items(words)
  let mut rng = { state: seed }
  if result.length() <= 1 {
    return result
  }
  for i = result.length() - 1; i > 0; i = i - 1 {
    let (next_rng, value) = lcg_next(rng)
    rng = next_rng
    let j = value % (i + 1)
    let temp = result[i]
    result[i] = result[j]
    result[j] = temp
  }
  result
}

///|
fn build_word_queue(words : Array[WordItem], size : Int) -> Array[WordItem] {
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
fn advance_word_queue(
  words : Array[WordItem],
  queue : Array[WordItem],
) -> Array[WordItem] {
  if words.length() == 0 {
    return []
  }
  if queue.length() == 0 {
    return build_word_queue(words, 10)
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
      word.roman == target.roman &&
      word.kind == target.kind {
      return Some(i)
    }
  }
  None
}

///|
struct Lcg {
  state : Int
}

///|
fn lcg_next(rng : Lcg) -> (Lcg, Int) {
  let next = (rng.state * 1664525 + 1013904223) & 0x7fffffff
  ({ state: next }, next)
}

///|
fn copy_word_items(words : Array[WordItem]) -> Array[WordItem] {
  let result : Array[WordItem] = []
  for word in words {
    result.push(word)
  }
  result
}
