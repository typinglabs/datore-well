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
  for text in datore_hiragana_words() {
    words.push({ text, kind: Hiragana })
  }
  for text in datore_katakana_words() {
    words.push({ text, kind: Katakana })
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
    "生{せい}活{かつ}", "中{なか}", "存{そん}在{ざい}", "彼{かれ}",
    "完{かん}走{そう}", "可{か}能{のう}性{せい}", "調{ちょう}子{し}",
    "時{じ}間{かん}", "正{せい}当{とう}", "手{しゅ}段{だん}", "選{せん}択{たく}",
    "資{し}料{りょう}", "詳{しょう}細{さい}", "参{さん}考{こう}",
    "相{そう}談{だん}", "彼{かれ}", "商{しょう}業{ぎょう}", "都{と}市{し}",
    "調{ちょう}査{さ}", "要{よう}請{せい}", "依{い}頼{らい}", "少{しょう}量{りょう}",
    "装{そう}置{ち}", "調{ちょう}整{せい}", "課{か}長{ちょう}",
    "相{そう}談{だん}", "校{こう}長{ちょう}", "先{せん}生{せい}",
    "教{きょう}頭{とう}", "先{せん}生{せい}", "今{こ}年{とし}",
    "定{てい}年{ねん}", "退{たい}職{しょく}", "高{こう}速{そく}",
    "楽{らく}勝{しょう}", "何{なん}度{ど}", "挑{ちょう}戦{せん}",
    "小{しょう}学{がく}生{せい}", "行{ぎょう}政{せい}法{ほう}",
    "解{かい}読{どく}", "大{だい}学{がく}", "通{つう}学{がく}",
    "時{じ}間{かん}", "異{い}様{よう}", "長{ちょう}文{ぶん}", "勝{しょう}負{ぶ}",
    "勝{しょう}利{り}", "早{そう}朝{ちょう}", "挑{ちょう}戦{せん}",
    "消{しょう}防{ぼう}士{し}", "相{そう}当{とう}", "苦{く}労{ろう}",
    "必{ひつ}要{よう}", "大{たい}切{せつ}", "話{はなし}", "相{あい}手{て}",
    "話{はなし}", "人{にん}間{げん}", "環{かん}境{きょう}", "毎{まい}日{にち}",
    "汚{お}染{せん}", "面{めん}接{せつ}", "対{たい}策{さく}", "擬{ぎ}似{じ}",
    "面{めん}接{せつ}", "視{し}力{りょく}", "低{てい}下{か}", "使{し}用{よう}",
    "映{えい}画{が}", "鑑{かん}賞{しょう}", "監{かん}督{とく}",
    "承{しょう}諾{だく}", "町{ちょう}長{ちょう}", "市{し}長{ちょう}",
    "相{そう}談{だん}", "市{し}長{ちょう}", "将{しょう}来{らい}",
    "健{けん}康{こう}",
  ]
}

///|
fn datore_katakana_words() -> Array[String] {
  [
    "インターネット", "タイピング", "サクサク", "ワクワク", "コンタクト",
    "ジョギング",
  ]
}

///|
fn datore_hiragana_words() -> Array[String] {
  [
    "して", "いく", "なくては", "ならない", "なりました", "なら",
    "する", "ある", "この", "なら", "かかりそうだ", "するには",
    "にして", "しよう", "について", "していた", "ようだ", "その",
    "したければ", "してください", "する", "そうだ", "すぎて",
    "する", "したことに", "した", "までの", "長{なが}いのは", "気{き}のせい",
    "だろうか", "父{とう}さん", "との", "するため", "から", "する",
    "なるためには", "お互{たが}い", "見{み}て", "しよう", "何{なに}気{げ}なく",
    "暮{く}らしている", "されて", "いる", "には", "前{まえ}もって",
    "やる", "怠{おこた}らない", "ように", "しましょう", "してきた",
    "感{かん}じ", "したため", "する", "ことに", "しました", "あの",
    "したいなら", "からの", "得{え}た", "いいよ", "さん", "したら",
    "それ", "応{おう}じて", "くれなかった", "ために", "する", "こと",
    "すばらしい", "感{かん}じています", "で", "は", "に", "は",
    "が", "が", "な", "を", "の", "を", "は", "を", "の", "を", "に",
    "と", "は", "に", "は", "と", "も", "は", "を", "が", "に", "で",
    "に", "に", "の", "を", "を", "は", "が", "は", "を", "が", "が",
    "を", "を", "を", "が", "が", "に", "に", "は", "の", "の", "を",
    "は", "と",
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
