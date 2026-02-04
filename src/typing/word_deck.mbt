///|
pub enum WordKind {
  Kanji
  Katakana
  Hiragana
} derive(Show, Eq)

///|
pub struct Word {
  text : String
  kind : WordKind
} derive(Show, Eq)

///|
pub struct WordDeck {
  mut words : Array[Word]
  mut index : Int
  mut rng : Lcg
}

///|
pub fn datore_words() -> Array[Word] {
  let words : Array[Word] = []
  for text in datore_kanji_words() {
    words.push({ text, kind: Kanji })
  }
  for text in datore_katakana_words() {
    words.push({ text, kind: Katakana })
  }
  for text in datore_hiragana_words() {
    words.push({ text, kind: Hiragana })
  }
  words
}

///|
pub fn filter_words(
  words : Array[Word],
  kinds : Array[WordKind],
) -> Array[Word] {
  let result : Array[Word] = []
  for word in words {
    if kind_allowed(kinds, word.kind) {
      result.push(word)
    }
  }
  result
}

///|
pub fn create_word_deck(words : Array[Word], seed : Int) -> WordDeck {
  let deck : WordDeck = {
    words: copy_words(words),
    index: 0,
    rng: { state: seed },
  }
  let (shuffled, rng) = shuffle_words(deck.words, deck.rng)
  deck.words = shuffled
  deck.rng = rng
  deck
}

///|
pub fn next_word(deck : WordDeck) -> (WordDeck, Word) {
  let next_deck = deck
  if next_deck.words.length() == 0 {
    abort("word deck is empty")
  }
  if next_deck.index >= next_deck.words.length() {
    let (shuffled, rng) = shuffle_words(next_deck.words, next_deck.rng)
    next_deck.words = shuffled
    next_deck.rng = rng
    next_deck.index = 0
  }
  let word = next_deck.words[next_deck.index]
  next_deck.index += 1
  (next_deck, word)
}

///|
fn kind_allowed(kinds : Array[WordKind], kind : WordKind) -> Bool {
  for current in kinds {
    if current == kind {
      return true
    }
  }
  false
}

///|
pub struct Lcg {
  state : Int
}

///|
fn shuffle_words(words : Array[Word], rng : Lcg) -> (Array[Word], Lcg) {
  let result = copy_words(words)
  let mut next_rng = rng
  if result.length() <= 1 {
    return (result, next_rng)
  }
  for i = result.length() - 1; i > 0; i = i - 1 {
    let (rng2, value) = lcg_next(next_rng)
    next_rng = rng2
    let j = value % (i + 1)
    let temp = result[i]
    result[i] = result[j]
    result[j] = temp
  }
  (result, next_rng)
}

///|
fn lcg_next(rng : Lcg) -> (Lcg, Int) {
  let next = (rng.state * 1664525 + 1013904223) & 0x7fffffff
  ({ state: next }, next)
}

///|
fn copy_words(words : Array[Word]) -> Array[Word] {
  let result : Array[Word] = []
  for word in words {
    result.push(word)
  }
  result
}

///|
fn datore_kanji_words() -> Array[String] {
  [
    "生活",
    "中",
    "存在",
    "彼",
    "完走",
    "可能性",
    "調子",
    "時間",
    "正当",
    "手段",
    "選択",
    "資料",
    "詳細",
    "参考",
    "相談",
    "彼",
    "商業",
    "都市",
    "調査",
    "要請",
    "依頼",
    "少量",
    "装置",
    "調整",
    "課長",
    "相談",
    "校長",
    "先生",
    "教頭",
    "先生",
    "今年",
    "定年",
    "退職",
    "高速",
    "楽勝",
    "何度",
    "挑戦",
    "小学生",
    "行政法",
    "解読",
    "大学",
    "通学",
    "時間",
    "異様",
    "長文",
    "勝負",
    "勝利",
    "早朝",
    "挑戦",
    "消防士",
    "相当",
    "苦労",
    "必要",
    "大切",
    "話",
    "相手",
    "話",
    "人間",
    "環境",
    "毎日",
    "汚染",
    "面接",
    "対策",
    "擬似",
    "面接",
    "視力",
    "低下",
    "使用",
    "映画",
    "鑑賞",
    "監督",
    "承諾",
    "町長",
    "市長",
    "相談",
    "市長",
    "将来",
    "健康",
  ]
}

///|
fn datore_katakana_words() -> Array[String] {
  ["インターネット", "タイピング", "サクサク", "ワクワク", "コンタクト", "ジョギング"]
}

///|
fn datore_hiragana_words() -> Array[String] {
  [
    "して",
    "いく",
    "なくては",
    "ならない",
    "なりました",
    "なら",
    "する",
    "ある",
    "この",
    "なら",
    "かかりそうだ",
    "するには",
    "にして",
    "しよう",
    "について",
    "していた",
    "ようだ",
    "その",
    "したければ",
    "してください",
    "する",
    "そうだ",
    "すぎて",
    "する",
    "したことに",
    "した",
    "までの",
    "長いのは",
    "気のせい",
    "だろうか",
    "父さん",
    "との",
    "するため",
    "から",
    "する",
    "なるためには",
    "お互い",
    "見て",
    "しよう",
    "何気なく",
    "暮らしている",
    "されて",
    "いる",
    "には",
    "前もって",
    "やる",
    "怠らない",
    "ように",
    "しましょう",
    "してきた",
    "感じ",
    "したため",
    "する",
    "ことに",
    "しました",
    "あの",
    "したいなら",
    "からの",
    "得た",
    "いいよ",
    "さん",
    "したら",
    "それ",
    "応じて",
    "くれなかった",
    "ために",
    "する",
    "こと",
    "すばらしい",
    "感じています",
    "で",
    "は",
    "に",
    "は",
    "が",
    "が",
    "な",
    "を",
    "の",
    "を",
    "は",
    "を",
    "の",
    "を",
    "に",
    "と",
    "は",
    "に",
    "は",
    "と",
    "も",
    "は",
    "を",
    "が",
    "に",
    "で",
    "に",
    "に",
    "の",
    "を",
    "を",
    "は",
    "が",
    "は",
    "を",
    "が",
    "が",
    "を",
    "を",
    "を",
    "が",
    "が",
    "に",
    "に",
    "は",
    "の",
    "の",
    "を",
    "は",
    "と",
  ]
}

///|
test "shuffle_wordsは同じseedで同じ順序になる" {
  let words = [
    { text: "A", kind: Kanji },
    { text: "B", kind: Kanji },
    { text: "C", kind: Kanji },
    { text: "D", kind: Kanji },
  ]
  let (result1, _) = shuffle_words(words, { state: 42 })
  let (result2, _) = shuffle_words(words, { state: 42 })
  assert_eq(result1[0].text, result2[0].text)
  assert_eq(result1[1].text, result2[1].text)
  assert_eq(result1[2].text, result2[2].text)
  assert_eq(result1[3].text, result2[3].text)
}

///|
test "word deckは末尾到達時にシャッフルして先頭から出題する" {
  let words = [
    { text: "A", kind: Kanji },
    { text: "B", kind: Kanji },
    { text: "C", kind: Kanji },
  ]
  let deck = create_word_deck(words, 1)
  let (deck, _) = next_word(deck)
  let (deck, _) = next_word(deck)
  let (deck, _) = next_word(deck)
  let (deck, word) = next_word(deck)
  assert_eq(deck.index, 1)
  assert_eq(word.text.length() > 0, true)
}
