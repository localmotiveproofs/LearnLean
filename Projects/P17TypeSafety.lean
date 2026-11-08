import Projects.P09Typed
/-!
# P17 · Type safety, two ways: intrinsic vs. extrinsic typing

**Part II** · ~6 hours · builds on: **P09** (the typed `Expr`, the untyped `UExpr`, your `check`)
· reused by: —

## Why
In P09 you built a language where ill-typed terms *can't be written* (intrinsic typing), so
type safety came for free. The traditional route (TAPL, Software Foundations) is
*extrinsic*: untyped terms, a separate typing relation, a small-step semantics, and the
**progress + preservation** theorems. Doing both for the same language shows what each
approach costs. The last part connects them: your P09 type checker is *sound* with respect to
the typing relation. That's where you'll meet `HEq` and casts, the real cost of dependent types.

## You'll learn
proofs over **indexed families** (`induction e` where `e : Expr t`) and dependent `match` in
proofs (`split` on a `match` whose patterns refine the index) · big inductive relations and
the `cases h with | add ha hb => …` idiom (Rocq's `inversion`) · `induction h generalizing t`
· `rcases`/`obtain` with `rfl` patterns · canonical-forms lemmas · reflexive-transitive closure ·
`HEq` (`≍`), `eq_of_heq`, `subst` and when `▸` gets in your way · `grind` for case explosions.

## Tasks
A. **Intrinsic**: `constFold` (fold `add`/`mul`/`lt`/`and`/`not` on literals, and pick an `ite`
   branch on a literal condition), then `constFold_correct`. No well-typedness lemma is
   needed. Why?
B. **Extrinsic**: canonical forms, `progress`, `preservation`, `soundness`, `hasType_unique`.
C. **Bridge**: `erase_hasType` (intrinsic terms erase to well-typed ones), and `check_sound`
   (about *your* P09 `check`).

## Done when
No `sorry` in this file, and `lake build Tests.P17TypeSafety` is green.

## Hints
* `progress`: induction on the typing derivation. In each congruence case, case on the IH for
  the left operand, then the right. When both are values, use canonical forms to expose the literals.
* `preservation`: induction on the *step*, generalizing `t`, then `cases` on the typing
  derivation. Each case is one line once you see the pattern.
* `check_sound` reflects how you wrote `check`. Expect goals like
  `h : t₁ = t ∧ ∃ x, a'.eq (x ▸ b') ≍ e`. The way out is `obtain ⟨rfl, hte, h⟩ := h`, then
  `subst hte`, then `cases eq_of_heq h`. If it's too painful, simplifying `check` is a
  legitimate fix.
* `grind` dispatches many of the small cases in part A after `split`.

## Stretch
* `check_complete : HasType u t → ∃ e, check u = some ⟨t, e⟩`.
* Big-step meets small-step: for every `e : Expr t`, `Steps e.erase (literal of e.eval)`.
  You'll want congruence lemmas for `Steps`.
* Determinism of `Step`.
-/

namespace P17
open P09

/-! ## A. Intrinsic -/

def constFold {t : Ty} : Expr t → Expr t := sorry

theorem constFold_correct {t : Ty} (e : Expr t) : (constFold e).eval = e.eval := sorry

/-! ## B. Extrinsic -/

inductive HasType : UExpr → Ty → Prop where
  | nat  {n : Nat} : HasType (.nat n) .nat
  | bool {b : Bool} : HasType (.bool b) .bool
  | add  {a b : UExpr} : HasType a .nat → HasType b .nat → HasType (.add a b) .nat
  | mul  {a b : UExpr} : HasType a .nat → HasType b .nat → HasType (.mul a b) .nat
  | lt   {a b : UExpr} : HasType a .nat → HasType b .nat → HasType (.lt a b) .bool
  | eq   {a b : UExpr} {t : Ty} : HasType a t → HasType b t → HasType (.eq a b) .bool
  | and  {a b : UExpr} : HasType a .bool → HasType b .bool → HasType (.and a b) .bool
  | not  {a : UExpr} : HasType a .bool → HasType (.not a) .bool
  | ite  {c a b : UExpr} {t : Ty} : HasType c .bool → HasType a t → HasType b t → HasType (.ite c a b) t

inductive Value : UExpr → Prop where
  | nat  (n : Nat) : Value (.nat n)
  | bool (b : Bool) : Value (.bool b)

inductive Step : UExpr → UExpr → Prop where
  | addL {a a' b : UExpr} : Step a a' → Step (.add a b) (.add a' b)
  | addR {a b b' : UExpr} : Value a → Step b b' → Step (.add a b) (.add a b')
  | add  {x y : Nat} : Step (.add (.nat x) (.nat y)) (.nat (x + y))
  | mulL {a a' b : UExpr} : Step a a' → Step (.mul a b) (.mul a' b)
  | mulR {a b b' : UExpr} : Value a → Step b b' → Step (.mul a b) (.mul a b')
  | mul  {x y : Nat} : Step (.mul (.nat x) (.nat y)) (.nat (x * y))
  | ltL  {a a' b : UExpr} : Step a a' → Step (.lt a b) (.lt a' b)
  | ltR  {a b b' : UExpr} : Value a → Step b b' → Step (.lt a b) (.lt a b')
  | lt   {x y : Nat} : Step (.lt (.nat x) (.nat y)) (.bool (decide (x < y)))
  | eqL  {a a' b : UExpr} : Step a a' → Step (.eq a b) (.eq a' b)
  | eqR  {a b b' : UExpr} : Value a → Step b b' → Step (.eq a b) (.eq a b')
  | eqN  {x y : Nat} : Step (.eq (.nat x) (.nat y)) (.bool (decide (x = y)))
  | eqB  {x y : Bool} : Step (.eq (.bool x) (.bool y)) (.bool (decide (x = y)))
  | andL {a a' b : UExpr} : Step a a' → Step (.and a b) (.and a' b)
  | andR {a b b' : UExpr} : Value a → Step b b' → Step (.and a b) (.and a b')
  | and  {x y : Bool} : Step (.and (.bool x) (.bool y)) (.bool (x && y))
  | notS {a a' : UExpr} : Step a a' → Step (.not a) (.not a')
  | not  {x : Bool} : Step (.not (.bool x)) (.bool !x)
  | iteC {c c' a b : UExpr} : Step c c' → Step (.ite c a b) (.ite c' a b)
  | iteT {a b : UExpr} : Step (.ite (.bool true) a b) a
  | iteF {a b : UExpr} : Step (.ite (.bool false) a b) b

inductive Steps : UExpr → UExpr → Prop where
  | refl {e : UExpr} : Steps e e
  | step {e₁ e₂ e₃ : UExpr} : Step e₁ e₂ → Steps e₂ e₃ → Steps e₁ e₃

theorem canonical_nat {e : UExpr} : Value e → HasType e .nat → ∃ n, e = .nat n := sorry

theorem canonical_bool {e : UExpr} : Value e → HasType e .bool → ∃ b, e = .bool b := sorry

theorem progress {e : UExpr} {t : Ty} : HasType e t → Value e ∨ ∃ e', Step e e' := sorry

theorem preservation {e e' : UExpr} {t : Ty} : HasType e t → Step e e' → HasType e' t := sorry

/-- Well-typed terms never get stuck. -/
theorem soundness {e e' : UExpr} {t : Ty} :
    HasType e t → Steps e e' → Value e' ∨ ∃ e'', Step e' e'' := sorry

theorem hasType_unique {e : UExpr} {t₁ t₂ : Ty} : HasType e t₁ → HasType e t₂ → t₁ = t₂ := sorry

/-! ## C. The bridge -/

theorem erase_hasType {t : Ty} (e : Expr t) : HasType e.erase t := sorry

/-- Your P09 type checker only produces terms that erase back to the input. -/
theorem check_sound {u : UExpr} {t : Ty} {e : Expr t} : check u = some ⟨t, e⟩ → e.erase = u := sorry

end P17
