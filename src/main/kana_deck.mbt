///|
struct WordItem {
  id : Int
  annotated : String
  display : String
  roman : String
  kana : String
  kind : @util.WordKind
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

///|
fn is_hiragana(ch : Char) -> Bool {
  (ch >= 'ぁ' && ch <= 'ゖ') || ch == 'ー'
}

///|
fn is_katakana(ch : Char) -> Bool {
  ch >= 'ァ' && ch <= 'ヶ'
}

///|
fn katakana_to_hiragana(ch : Char) -> Char {
  if is_katakana(ch) {
    (ch.to_int() - 0x60).unsafe_to_char()
  } else {
    ch
  }
}

///|
fn build_kana_from_annotated(annotated : String) -> String {
  let chars : Array[Char] = []
  for ch in annotated.iter() {
    chars.push(ch)
  }
  let mut i = 0
  let mut kana = ""
  while i < chars.length() {
    let ch = chars[i]
    if ch == '{' {
      i += 1
      continue
    }
    if ch == '}' {
      i += 1
      continue
    }
    if i + 1 < chars.length() && chars[i + 1] == '{' {
      let mut j = i + 2
      let mut reading = ""
      while j < chars.length() && chars[j] != '}' {
        reading += chars[j].to_string()
        j += 1
      }
      kana += reading
      i = j + 1
      continue
    }
    if is_hiragana(ch) {
      kana += ch.to_string()
    } else if is_katakana(ch) {
      kana += katakana_to_hiragana(ch).to_string()
    }
    i += 1
  }
  kana
}

///|
fn init_all_items() -> Array[WordItem] {
  let items : Array[WordItem] = []
  let words = @util.datore_words()
  for i = 0; i < words.length(); i = i + 1 {
    let word = words[i]
    let result = try {
      let (kanji_state, _apply_key) = @romaji_typing.create_kanji_engine(
        word.text,
      )
      Some({
        id: i,
        annotated: word.text,
        display: kanji_state.display,
        roman: kanji_state.remaining_romaji,
        kana: build_kana_from_annotated(word.text),
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
fn filter_words(category : Category, filter : String) -> Array[WordItem] {
  let result : Array[WordItem] = []
  for word in all_items {
    let allowed = match (category, word.kind) {
      (All, _) => true
      (Kanji, @util.Kanji) => true
      (Katakana, @util.Katakana) => true
      (Hiragana, @util.Hiragana) => true
      (_, _) => false
    }
    if allowed && (filter == "" || word.kana.contains(filter)) {
      result.push(word)
    }
  }
  result
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
    return []
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
fn find_word_index(words : Array[WordItem], target : WordItem) -> Int? {
  for i = 0; i < words.length(); i = i + 1 {
    let word = words[i]
    if word.id == target.id {
      return Some(i)
    }
  }
  None
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
