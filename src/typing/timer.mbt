///|
pub enum TimerState {
  Stopped
  Running
  Finished
} derive(Show, Eq)

///|
pub struct Timer {
  limit_ms : Int
  elapsed_ms : Int
  state : TimerState
} derive(Show, Eq)

///|
pub fn create_timer(limit_ms : Int) -> Timer {
  { limit_ms, elapsed_ms: 0, state: Stopped }
}

///|
pub fn start_timer(timer : Timer) -> Timer {
  if timer.state == Finished {
    timer
  } else {
    { ..timer, state: Running }
  }
}

///|
pub fn stop_timer(timer : Timer) -> Timer {
  if timer.state == Running {
    { ..timer, state: Stopped }
  } else {
    timer
  }
}

///|
pub fn reset_timer(timer : Timer) -> Timer {
  { ..timer, elapsed_ms: 0, state: Stopped }
}

///|
pub fn tick_timer(timer : Timer, delta_ms : Int) -> Timer {
  if delta_ms <= 0 || timer.state != Running {
    return timer
  }
  let next_elapsed = timer.elapsed_ms + delta_ms
  if timer.limit_ms > 0 && next_elapsed >= timer.limit_ms {
    { ..timer, elapsed_ms: timer.limit_ms, state: Finished }
  } else {
    { ..timer, elapsed_ms: next_elapsed }
  }
}

///|
pub fn remaining_ms(timer : Timer) -> Int {
  if timer.limit_ms <= 0 {
    0
  } else {
    let remaining = timer.limit_ms - timer.elapsed_ms
    if remaining < 0 { 0 } else { remaining }
  }
}

///|
pub fn is_finished(timer : Timer) -> Bool {
  timer.state == Finished
}

///|
test "timerは開始前は停止で経過0" {
  let timer = create_timer(1000)
  assert_eq(timer.state, Stopped)
  assert_eq(timer.elapsed_ms, 0)
}

///|
test "timerは停止中のtickを無視する" {
  let timer = create_timer(1000)
  let timer = tick_timer(timer, 500)
  assert_eq(timer.elapsed_ms, 0)
}

///|
test "timerは開始後に経過時間が進む" {
  let timer = create_timer(1000)
  let timer = start_timer(timer)
  let timer = tick_timer(timer, 400)
  assert_eq(timer.elapsed_ms, 400)
  assert_eq(timer.state, Running)
}

///|
test "timerは制限時間を超えると終了する" {
  let timer = create_timer(1000)
  let timer = start_timer(timer)
  let timer = tick_timer(timer, 1200)
  assert_eq(timer.elapsed_ms, 1000)
  assert_eq(timer.state, Finished)
  assert_eq(remaining_ms(timer), 0)
}

///|
test "timerは終了後に再開できない" {
  let timer = create_timer(100)
  let timer = start_timer(timer)
  let timer = tick_timer(timer, 200)
  let timer = start_timer(timer)
  assert_eq(timer.state, Finished)
}
