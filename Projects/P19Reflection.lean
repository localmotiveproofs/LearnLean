import Lean
import Projects.P04Algebra
import Projects.P13Sorting
/-!
# P19 · Proof by reflection: a verified normalizer and the tactic that drives it

**Part II** · ~6 hours · builds on: **P04** (your `Monoid` class), **P13** (`isort`,
`isort_perm`), **P18** (`elab`, `MetaM`) · reused by: —

## Why
This is how industrial-strength tactics like `ring`, `ac_rfl` and `omega` work. You write a
**normalizer** as an ordinary function on a syntax tree, prove it correct *once*, and then
each proof is a single computation that the kernel checks. Proof terms stay tiny no matter
how big the goal is. You know the idea from Rocq's `ring`. Here you'll build both halves: the
verified core *and* the meta-level "reification" that turns a goal `a * (b * 1) = …` into
an `MExpr` AST. It's the most "aha" project in the series.

## You'll learn
`extends` for lawful classes · `deriving Lean.ToExpr` (turning runtime values back into
`Expr` syntax trees) · `Expr` inspection: `isAppOfArity`, `getArg!`, `eq?`, `rawNatLit?` ·
`StateT (Array Expr) MetaM` to collect atoms (deduplicated *up to defeq* with `isDefEq`) ·
building terms: `mkListLit`, `mkAppM`, `mkEqRefl`, `toExpr` · checking your proof term with
`inferType` + `isDefEq` before assigning it · why the kernel accepts `Eq.refl` for
`flatten e₁ = flatten e₂`: it *evaluates* both sides.

## Tasks
1. `LawfulMonoid` instances for `String` and `Nat` (`Nat` is even commutative).
2. The verified core: `denote`, `flatten`, `denoteList`, then `denoteList_append`,
   `flatten_correct` and `monoid_reflect`.
3. The tactic `monoid_rfl`: reify both sides of the goal, check that the normal forms agree
   *at meta level* (and fail with a clear message if not), then build the proof
   `monoid_reflect ρ e₁ e₂ (Eq.refl _)` and close the goal.
4. Commutative version: `denoteList_perm` and `comm_reflect` (normalize by sorting the atom
   indices with your **P13** `isort`, so `isort_perm` does the work), plus `comm_monoid_rfl`.

## Done when
No `sorry` in this file, and `lake build Tests.P19Reflection` is green.

## Hints
* `a * b` elaborates to `@HMul.hMul α α α inst a b` (6 arguments). The literal `1` is
  `@OfNat.ofNat α 1 inst` (3 arguments, and argument 1 is a raw literal). Use
  `#check (fun (a b : Nat) => a * b)` with `set_option pp.all true` to see for yourself.
* Reifier skeleton: `partial def reify (e : Expr) : StateT (Array Expr) MetaM MExpr`. Anything
  that's neither a product nor `1` becomes an atom. Look it up in the array with `isDefEq`, or push it.
* Environment: `ρ ← mkListLit α atoms.toList`, and atom `i` denotes `ρ.getD i 1`.
* Close with `goal.assign proof; replaceMainGoal []`, but only after
  `isDefEq (← inferType proof) target`. Otherwise you'll get a kernel error later, far from the cause.

## Stretch
* Compare with core's `ac_rfl` and with `grind` on the same goals, and time them on a
  50-atom goal. Reflection should win.
* Extend to commutative *semirings*: a mini `ring_nf` over `Nat`. Normal forms become sorted
  lists of monomials.
-/

namespace P19
open P04

class LawfulMonoid (α : Type) extends Monoid α where
  mul_assoc : ∀ a b c : α, a * b * c = a * (b * c)
  one_mul : ∀ a : α, 1 * a = a
  mul_one : ∀ a : α, a * 1 = a

class LawfulCommMonoid (α : Type) extends LawfulMonoid α where
  mul_comm : ∀ a b : α, a * b = b * a

instance : LawfulMonoid String := sorry
instance : LawfulCommMonoid Nat := sorry

/-- Monoid expressions over atoms numbered `0, 1, 2, …`. -/
inductive MExpr where
  | atom (i : Nat)
  | one
  | mul (a b : MExpr)
deriving DecidableEq, Repr, Lean.ToExpr

section
variable {α : Type} [Monoid α]

/-- Atom `i` denotes `ρ.getD i 1`. -/
def MExpr.denote (ρ : List α) : MExpr → α := sorry

/-- The list of atoms, left to right (`one` contributes nothing). -/
def MExpr.flatten : MExpr → List Nat := sorry

/-- `denoteList ρ [i, j, k] = ρ[i] * (ρ[j] * (ρ[k] * 1))` (with `getD … 1` lookups). -/
def denoteList (ρ : List α) : List Nat → α := sorry
end

section
variable {α : Type} [LawfulMonoid α]

theorem denoteList_append (ρ : List α) (xs ys : List Nat) :
    denoteList ρ (xs ++ ys) = denoteList ρ xs * denoteList ρ ys := sorry

theorem flatten_correct (ρ : List α) (e : MExpr) : denoteList ρ e.flatten = e.denote ρ := sorry

theorem monoid_reflect (ρ : List α) (e₁ e₂ : MExpr) (h : e₁.flatten = e₂.flatten) :
    e₁.denote ρ = e₂.denote ρ := sorry
end

theorem denoteList_perm {α : Type} [LawfulCommMonoid α] (ρ : List α) {xs ys : List Nat}
    (h : xs.Perm ys) : denoteList ρ xs = denoteList ρ ys := sorry

theorem comm_reflect {α : Type} [LawfulCommMonoid α] (ρ : List α) (e₁ e₂ : MExpr)
    (h : P13.isort e₁.flatten = P13.isort e₂.flatten) : e₁.denote ρ = e₂.denote ρ := sorry

/-! ## The tactics: `monoid_rfl` and `comm_monoid_rfl` (your `elab`s go here) -/

end P19
