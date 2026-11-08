import Projects.P07Macros
/-! Acceptance tests for P07. `lake build Tests.P07Macros` -/
open P06 P07

-- 1. notation
example : 17 ≡ 2 [MOD 5] := by decide
example : ¬ (17 ≡ 3 [MOD 5]) := by decide

-- 2. hygiene
#guard (let x := 10; twice! (x + 1)) == 22

-- 3. json%
#guard (json% null) == JSON.null
#guard (json% { "a": [1, -2, null], "b": { "c": true }, "s": "x", "e": [], "f": false })
  == .obj [("a", .arr [.num ⟨1, 0⟩, .num ⟨-2, 0⟩, .null]), ("b", .obj [("c", .bool true)]),
           ("s", .str "x"), ("e", .arr []), ("f", .bool false)]
#guard (let n := 3; json% [(JSON.num ⟨n + 1, 0⟩), (.str "hi")]) == .arr [.num ⟨4, 0⟩, .str "hi"]
-- `null` must still be usable as an ordinary identifier
def null := 5
#guard null == 5

-- 4. list comprehensions
#guard [x * y | x ← [1, 2, 3], y ← [10, 20], if x != 2] == [10, 20, 30, 60]
#guard [(a, b, c) | c ← List.range 21, b ← List.range c, a ← List.range b, if a > 0, if a*a + b*b == c*c]
  == [(3, 4, 5), (6, 8, 10), (5, 12, 13), (9, 12, 15), (8, 15, 17), (12, 16, 20)]
#guard [x | x ← [1, 2, 3, 4], if x % 2 == 0] == [2, 4]
#guard [1, 2, 3] == [1, 2, 3]

-- 5. enum
enum Color { red, green, blue }
#guard Color.all == [.red, .green, .blue]
#guard toString Color.green == "green"
#guard Color.all.map toString == ["red", "green", "blue"]
example : Color.red ≠ Color.blue := by decide

-- 6. #expect
#expect 1 + 1 == 2
#expect "ab" ++ "c" == "abc"
/-- error: expected 3, got 2 -/
#guard_msgs in #expect 1 + 1 == 3
/-- error: expected [3], got [1, 2] -/
#guard_msgs in #expect [1, 2] == [3]
