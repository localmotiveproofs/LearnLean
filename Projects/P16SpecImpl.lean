import Std.Tactic.Do
/-!
# P16 · Spec vs. implementation: verifying imperative `do` code, and `@[csimp]`

**Part II** · ~4 hours · builds on: P05/P10 (you wrote lots of `Id.run do` loops), P13 (`@[csimp]`)

## Why
In Part I you wrote imperative-looking code: `let mut`, `for`, early `return`. Is it correct?
Lean has a dedicated framework for this: `Std.Do`, with Hoare-style specs and a
verification-condition generator, **`mvcgen`**. You state a *loop invariant*. `mvcgen` turns
your `do` block into plain goals, and `simp`/`omega`/`grind` usually finish them. You'll also
write a non-structural recursion (binary search) whose array accesses are *proved* in bounds,
and use `@[csimp]` to make an exponential spec run linearly.

## You'll learn
`Std.Do`: `Id.of_wp_run_eq`, `mvcgen`, invariants written `⇓⟨cur, state⟩ => ⌜…⌝`, where
`cur.prefix` is the list of elements already visited · `simp_all +zetaDelta` to see through
`let`s introduced by `do` · `if h : … then arr[i] else …` (bounds proofs from the
condition) · `termination_by hi - lo` · `fun_induction` with named cases · reasoning about
sortedness via `List.pairwise_iff_getElem` · `@[csimp]` and what it changes (compiled code only:
the kernel still sees `fibSpec`).

## Tasks
1. `fibLoop` (two `let mut`s and a `for` over `[0:n]`), `fibLoop_eq`, then the `@[csimp]`
   theorem. Afterwards `#eval fibSpec 200` is instant.
2. `sumSquares` (a `for` over an `Array`) and its spec.
3. `maxOf?` with an `Option` accumulator. Find **one** invariant that gives *both* theorems.
4. `binSearch` on a sorted array: soundness (no sortedness needed!) and completeness.

## Done when
No `sorry` in this file, and `lake build Tests.P16SpecImpl` is green.

## Hints
* The recipe, verified against Lean 4.35:
  ```
  theorem foo_eq : foo x = spec x := by
    generalize h : foo x = r
    apply Id.of_wp_run_eq h
    mvcgen
    case inv1 => exact ⇓⟨cur, s⟩ => ⌜s = (cur.prefix.map f).sum⌝
    all_goals simp_all
  ```
  In 4.35, `mvcgen` prints a deprecation notice pointing to `vcgen`, its experimental
  successor, which couldn't handle these goals in testing. Silence the notice with
  `set_option linter.deprecated.syntax false`. With several mutable variables the state is a
  tuple: `⇓⟨cur, (a, b)⟩ => …`.
* Read the Lean reference manual's chapter on `mvcgen` / `Std.Do`. It's short and has examples.
* `binSearch_complete`: generalize to the helper with an arbitrary window `[lo, hi)` that is
  known to contain `x`, then `fun_induction` on the helper.

## Stretch
* `@[csimp]` for P04's `npow` against a naive `pow`. Prove `npow x n = pow x n` for any monoid
  with associativity (P19 adds the laws to the class).
* A `while` loop: Lean's `while` is `partial`, so how *do* you reason about it? Read about
  `Std.Do` + `Loop` and `partial_fixpoint`.
-/

namespace P16

def fibSpec : Nat → Nat
  | 0 => 0
  | 1 => 1
  | n + 2 => fibSpec n + fibSpec (n + 1)

/-- Imperative Fibonacci: `Id.run do` with `let mut a b` and `for _ in [0:n]`. -/
def fibLoop (n : Nat) : Nat := sorry

theorem fibLoop_eq (n : Nat) : fibLoop n = fibSpec n := sorry

/-- Tag this `@[csimp]` once it's proved. -/
theorem fibSpec_eq_fibLoop : @fibSpec = @fibLoop := sorry

/-- Imperative: `let mut s := 0; for x in xs do s := s + x * x`. -/
def sumSquares (xs : Array Nat) : Nat := sorry

theorem sumSquares_eq (xs : Array Nat) : sumSquares xs = (xs.toList.map (· ^ 2)).sum := sorry

/-- Imperative: an `Option Nat` accumulator updated in a `for` loop. -/
def maxOf? (xs : List Nat) : Option Nat := sorry

theorem maxOf?_spec (xs : List Nat) (m : Nat) :
    maxOf? xs = some m → m ∈ xs ∧ ∀ x ∈ xs, x ≤ m := sorry

theorem maxOf?_eq_none (xs : List Nat) : maxOf? xs = none ↔ xs = [] := sorry

/-- Index of *some* occurrence of `x`, searching a sorted array by halving `[lo, hi)`. -/
def binSearch (arr : Array Nat) (x : Nat) : Option Nat := sorry

theorem binSearch_sound (arr : Array Nat) (x i : Nat) :
    binSearch arr x = some i → arr[i]? = some x := sorry

theorem binSearch_complete (arr : Array Nat) (x : Nat) (hs : arr.toList.Pairwise (· ≤ ·))
    (hx : x ∈ arr) : (binSearch arr x).isSome := sorry

end P16
