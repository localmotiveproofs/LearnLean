import Projects.P18Tactics
/-! Acceptance tests for P18. `lake build Tests.P18Tactics` -/
set_option linter.unusedVariables false
open P18

-- split_ands
example (p q r : Prop) (hp : p) (hq : q) (hr : r) : p ∧ (q ∧ r) ∧ p := by
  split_ands <;> assumption
example (p : Prop) (hp : p) : p := by split_ands; exact hp

-- crush
example (a b : Nat) (h : a < b) : a + 1 ≤ b := by crush
example (xs : List Nat) : (xs ++ []).length = xs.length := by crush
example : 2 + 2 = 4 := by crush
example (p q : Prop) (hp : p) (hpq : p → q) : q := by crush
example (x : Nat) : x = x + 0 := by crush

-- my_trivial (extensible: several macro_rules)
example (p : Prop) (h : p) : p ∧ (1 = 1) ∧ (3 < 5) := by my_trivial
example : True ∧ 10 ≠ 11 := by my_trivial

-- exact_any
example (h1 : 1 = 2) (h2 : 3 = 3) : 3 = 3 := by exact_any [h1, h2]
example : 3 = 3 := by exact_any [rfl]
example : True := by
  fail_if_success exact_any [(rfl : 1 = 1)]
  trivial

-- trace_goal
/-- info: goal: 1 + 1 = 2 -/
#guard_msgs in example : 1 + 1 = 2 := by trace_goal; rfl

-- my_assumption
example (p q : Prop) (hp : p) (hq : q) : q := by my_assumption
example (n : Nat) (h : n + 0 = 5) : n = 5 := by my_assumption   -- up to defeq!
example (p : Prop) (hp : p) : True := by
  fail_if_success (have : 1 = 2 := by my_assumption)
  trivial

-- destruct_ands
example (p q r : Prop) (h : p ∧ (q ∧ r)) : r := by destruct_ands; assumption
example (p q : Prop) (h₁ : p ∧ q) (h₂ : q ∧ p) : p ∧ q := by
  destruct_ands; exact ⟨‹p›, ‹q›⟩
