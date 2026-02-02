///|
priv struct Rule {
  input : String
  output : String
  nextInput : String?
}

///|
struct ProcessOutput {
  buffer : String
  output : String
} derive(Eq, Show)

///|
fn findRules(input : String) -> Array[Rule] {
  table.filter(rule => rule.input == input)
}

///|
fn findRulesByPrefix(input : String) -> Array[Rule] {
  table.filter(rule => rule.input.has_prefix(input))
}

///|
fn optionToString(option : String?) -> String {
  match option {
    Some(x) => x
    None => ""
  }
}

///|
fn process(buffer : String, key : Char) -> ProcessOutput {
  // 現在の入力バッファーがbufferで、keyを押したときの処理を書く
  let newBuffer = buffer + key.to_string()
  let rules = findRules(newBuffer)
  if rules.length() > 0 {
    // バッファーに合致するルールがある場合
    if rules.length() == 1 {
      // 合致するルールが1つだけ→それを使って変換する
      let rule = rules[0]
      return { output: rule.output, buffer: optionToString(rule.nextInput) }
    } else {
      // それ以外の場合→保留する
      return { output: "", buffer: newBuffer }
    }
  } else {
    // バッファーに合致するルールがない場合
    let prefixRules = findRulesByPrefix(newBuffer)
    if prefixRules.length() > 0 {
      // 前方一致するルールがある場合→保留する
      return { output: "", buffer: newBuffer }
    } else {
      // 完全一致、前方一致がともにない場合は、変換する
      // nk → んk のような場合
      let mut output = ""
      let mut buffer = ""
      match newBuffer[:] {
        [] => return { buffer: newBuffer, output: "" }
        [first, .. rest] => {
          let buffer_left = first.to_string()
          let buffer_right = rest.to_string()
          let rules = findRules(buffer_left)
          if rules.length() > 0 {
            let rule = rules[0]
            output += rule.output
            buffer += optionToString(rule.nextInput)
          } else {
            output += newBuffer
          }
          buffer += buffer_right
          return { buffer, output }
        }
      }
    }
  }
}

///|
fn process_keys(keys : String) -> ProcessOutput {
  let mut buffer = ""
  let mut output = ""
  for key in keys.iter() {
    let result = process(buffer, key)
    output += result.output
    buffer = result.buffer
  }
  return { buffer, output }
}

///|
test "process / aiueo -> あいうえお" {
  assert_eq(process_keys("aiueo"), { output: "あいうえお", buffer: "" })
}

///|
test "process / kakikukeko -> かきくけこ" {
  assert_eq(process_keys("kakikukeko"), {
    output: "かきくけこ",
    buffer: "",
  })
}

///|
test "process / sanka -> さんか" {
  assert_eq(process_keys("sanka"), { output: "さんか", buffer: "" })
}

///|
test "process / si, shi -> し" {
  assert_eq(process_keys("si"), { output: "し", buffer: "" })
  assert_eq(process_keys("shi"), { output: "し", buffer: "" })
}

///|
test "process / tu, tsu -> つ" {
  assert_eq(process_keys("tu"), { output: "つ", buffer: "" })
  assert_eq(process_keys("tsu"), { output: "つ", buffer: "" })
}

///|
test "process / sya, sha, sixya, silya -> しゃ" {
  assert_eq(process_keys("sya"), { output: "しゃ", buffer: "" })
  assert_eq(process_keys("sha"), { output: "しゃ", buffer: "" })
  assert_eq(process_keys("sixya"), { output: "しゃ", buffer: "" })
  assert_eq(process_keys("silya"), { output: "しゃ", buffer: "" })
}

///|
test "process / u, wu, whu -> う" {
  assert_eq(process_keys("u"), { output: "う", buffer: "" })
  assert_eq(process_keys("wu"), { output: "う", buffer: "" })
  assert_eq(process_keys("whu"), { output: "う", buffer: "" })
}

///|
test "process / i, yi -> い" {
  assert_eq(process_keys("i"), { output: "い", buffer: "" })
  // assert_eq(process_keys("yi"), { output: "い", buffer: "" })
}

///|
test "process / tta, ltuta, xtuta -> った" {
  assert_eq(process_keys("tta"), { output: "った", buffer: "" })
  assert_eq(process_keys("ltuta"), { output: "った", buffer: "" })
  assert_eq(process_keys("xtuta"), { output: "った", buffer: "" })
}
