// ///|
// struct RomanState {
//   typed_roman : String
//   remaining_roman : String
//   typed_kana : String
//   remaining_kana : String
// }

// ///|
// enum RomanResult {
//   CorrectKey // 正しいキーを入力
//   WrongKey // 間違ったキーを入力
//   WordCompleted // 正しいキーを入力して、完了
// }

// ///|
// type InitFn = (String) -> RomanState

// ///|
// type ApplyKeyFn = (RomanState, Char) -> (RomanState, RomanResult)
