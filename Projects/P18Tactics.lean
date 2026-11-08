import Lean
/-!
# P18 · Writing your own tactics: from `macro` to `elab` and `MetaM`

**Part II** · ~4 hours · builds on: **P07** (macros), P11–P17 (you know which proofs were
tedious) · reused by: **P19** (a reflective tactic)

## Why
In Rocq you'd reach for Ltac (or Ltac2, or a plugin in OCaml). In Lean, tactics are ordinary
Lean programs, written with the same macro system you used in P07, or as **elaborators** that
run in the `TacticM` monad with full access to goals, the local context and the type checker.
There's no separate language and no plugin boundary. This project gets you over the
"metaprogramming looks scary" hump.

## You'll learn
`macro "name" : tactic => `(tactic| …)` · tactic combinators: `first | … | …`, `<;>`,
`repeat'`, `try`, `done`, `fail "msg"`, `fail_if_success` · **extensible tactics**: several
`macro_rules` for one `syntax`, tried newest-first with backtracking (this is how core's
`trivial` and `decreasing_tactic` are extensible) · `elab "name" : tactic => do …` ·
`getMainGoal`, `MVarId.getType`, `withMainContext`, `getLCtx`, `LocalDecl`,
`isDefEq`, `MVarId.assign`, `replaceMainGoal` · `logInfo`, `throwError`, and `m!"…"`
messages · running syntax from inside an elaborator with `evalTactic (← `(tactic| …))`.

## Tasks (all exercised by `Tests/P18Tactics.lean`)
Macro tactics:
1. `split_ands`: repeatedly split `∧` goals, and nothing else.
2. `crush`: a "try the obvious" tactic: `omega`, `decide`, `intros; simp_all`, and
   `intros; simp_all; omega`. It must either close the goal or fail, with no partial progress.
3. `my_trivial`: one `syntax` and **four** separate `macro_rules`: `rfl`, `assumption`,
   `decide`, and splitting `∧` then recursing with `my_trivial`.
4. `exact_any [t₁, t₂, …]`: the first term that typechecks against the goal wins.

`elab` tactics:
5. `trace_goal`: logs `goal: <type>` as info.
6. `my_assumption`: your own `assumption`. Walk the local context and close the goal with the
   first hypothesis whose type is *definitionally* equal to it. Otherwise fail.
7. `destruct_ands`: split *every* hypothesis `h : A ∧ B` in context, recursively, until no
   conjunctions are left.

Then **use them**: go back and shorten three proofs from P11–P17 with `crush`/`my_trivial`.

## Done when
`lake build Tests.P18Tactics` is green.

## Hints
* The worked example below shows the `elab` boilerplate. `withMainContext` matters: without
  it, you're looking at the *wrong* local context.
* Skip hypotheses with `decl.isImplementationDetail` (auxiliary `let`s and the like).
* For `destruct_ands`, finding the hypothesis is the metaprogramming part. Destructing it is
  easiest with `evalTactic (← `(tactic| obtain ⟨_, _⟩ := $(mkIdent decl.userName)))`. Then
  start over, because the local context changed.
* `whnfR` before checking `isAppOf ``And` lets you see through reducible definitions.

## Stretch
* `my_constructor`: apply the first constructor of the goal's inductive type whose
  conclusion unifies (`getConstInfoInduct`, `forallMetaTelescopeReducing`, `MVarId.apply`).
* A `#count_constructors T` *command* elaborator (`elab "#…" : command`).
* `tauto`-lite for propositional logic: intros, destruct ∧/∨/∃ in hypotheses, split ∧/↔,
  try both sides of ∨, `contradiction`.
-/

namespace P18
open Lean Elab Tactic Meta

/-! ## Worked example: an `elab` tactic that inspects the goal -/

/-- Succeeds iff the goal is an equation, and logs its two sides. -/
elab "show_eq_sides" : tactic => withMainContext do
  let goal ← getMainGoal
  let ty ← instantiateMVars (← goal.getType)
  match ty.eq? with
  | some (_, lhs, rhs) => logInfo m!"lhs: {lhs}, rhs: {rhs}"
  | none => throwError "show_eq_sides: goal is not an equation:{indentExpr ty}"

/-- info: lhs: 2 + 2, rhs: 4 -/
#guard_msgs in example : 2 + 2 = 4 := by show_eq_sides; rfl

/-! ## Your tactics go here -/

end P18
