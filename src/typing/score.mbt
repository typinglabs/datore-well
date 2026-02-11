///|
pub struct ScoreInput {
  correct_keys : Int
  mistakes : Int
  elapsed_ms : Int
} derive(Show, Eq)

///|
pub struct Score {
  total_keys : Int
  accuracy_percent : Int
  wpm : Int
  cpm : Int
} derive(Show, Eq)

///|
pub fn calc_score(input : ScoreInput) -> Score {
  let total_keys = input.correct_keys + input.mistakes
  let accuracy_percent = if total_keys == 0 {
    100
  } else {
    input.correct_keys * 100 / total_keys
  }
  let (wpm, cpm) = calc_speed(input.correct_keys, input.elapsed_ms)
  { total_keys, accuracy_percent, wpm, cpm }
}

///|
pub fn calc_score_from(
  correct_keys : Int,
  mistakes : Int,
  elapsed_ms : Int,
) -> Score {
  calc_score({ correct_keys, mistakes, elapsed_ms })
}

///|
fn calc_speed(correct_keys : Int, elapsed_ms : Int) -> (Int, Int) {
  if elapsed_ms <= 0 {
    return (0, 0)
  }
  let cpm = correct_keys * 60000 / elapsed_ms
  let wpm = correct_keys * 60000 / (elapsed_ms * 5)
  (wpm, cpm)
}

///|
test "calc_scoreは正確率と速度を算出できる" {
  let input : ScoreInput = {
    correct_keys: 300,
    mistakes: 30,
    elapsed_ms: 60000,
  }
  let score = calc_score(input)
  assert_eq(score.total_keys, 330)
  assert_eq(score.accuracy_percent, 90)
  assert_eq(score.cpm, 300)
  assert_eq(score.wpm, 60)
}

///|
test "calc_scoreは経過時間0なら速度を0にする" {
  let input : ScoreInput = { correct_keys: 10, mistakes: 0, elapsed_ms: 0 }
  let score = calc_score(input)
  assert_eq(score.wpm, 0)
  assert_eq(score.cpm, 0)
}
