///|
struct WordItem {
  annotated : String
  display : String
  roman : String
  kana : String
  kind : @util.WordKind
}

///|
let queue_rng : @random.Rand = @random.Rand::new()

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
  for word in words {
    let result = try {
      let (kanji_state, _apply_key) = @romaji_typing.create_kanji_engine(
        word.text,
      )
      Some({
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
  all_items.filter(word => {
    let allowed = match (category, word.kind) {
      (All, _) => true
      (Kanji, @util.Kanji) => true
      (Katakana, @util.Katakana) => true
      (Hiragana, @util.Hiragana) => true
      (_, _) => false
    }
    allowed && (filter == "" || word.kana.contains(filter))
  })
}

///|
fn build_word_queue(
  words : Array[WordItem],
  size : Int,
) -> @deque.Deque[WordItem] {
  if words.length() == 0 {
    return @deque.new()
  }
  let queue : @deque.Deque[WordItem] = @deque.new()
  for _i = 0; _i < size; _i = _i + 1 {
    let next_index = queue_rng.int(limit=words.length())
    queue.push_back(words[next_index])
  }
  queue
}

///|
fn advance_word_queue(
  words : Array[WordItem],
  queue : @deque.Deque[WordItem],
) -> @deque.Deque[WordItem] {
  if words.length() == 0 {
    return @deque.new()
  }
  if queue.length() == 0 {
    return build_word_queue(words, 10)
  }
  queue.pop_front() |> ignore
  let next_index = queue_rng.int(limit=words.length())
  queue.push_back(words[next_index])
  queue
}
