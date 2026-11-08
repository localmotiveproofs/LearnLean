/-!
# P04 · Typeclass algebra: polynomials, `Fin`-indexed matrices, and `fib 10000` in a blink

**Part I** · ~4 hours · builds on: P01 · reused by: **P16** (fast-vs-spec proofs),
**P19** (your `Monoid` class becomes the target of a reflective tactic)

## Why
Typeclasses are Lean's answer to both OCaml functors and Scala implicits, and they drive all
notation: `+`, `*`, numeric literals and `x[i]` all go through classes. You'll also get your
**first dependent type**, used gently: a matrix whose *dimensions are in its type*, so a
dimension mismatch is a compile-time error.

## You'll learn
`class` / `instance` / `extends` · how notation is wired: `a * b` is `HMul.hMul a b`, which falls
back to `Mul`; `1` is `OfNat α 1`, which falls back to `One` · writing `OfNat` instances so
literals work for *your* types · `ToString` · generic code over a class (`npow` works for
`Nat`, `String`, matrices and polynomials alike) · `Fin n` and `Vector α n` (an array whose length is in its type) ·
`#check_failure` · `termination_by` for divide-and-conquer recursion.

## Tasks
1. **Monoid & `npow`.** Instances for `Nat` (under `*`) and `String` (under `++`). `npow` must
   use *repeated squaring*: O(log n) multiplications.
2. **Matrices.** `Matrix m n α` wraps a `Vector (Vector α n) m`. Implement `ofFn`, `get`, and `HMul` so that
   `(A : Matrix m k α) * (B : Matrix k n α) : Matrix m n α`, plus a `Monoid (Matrix n n α)`
   instance (identity matrix). `fibFast n` is the top-right entry of `[[1,1],[1,0]]^n`.
   Check that `fibFast 10000` is instant (`#eval (toString (fibFast 10000)).length`).
3. **Polynomials** over any `[Add α] [Mul α] [Zero α] [One α] [BEq α]`, stored as
   coefficient lists with the *lowest degree first* and *no trailing zeros* (normal form!).
   Provide `+`, `*`, `X`, constants via `OfNat`, `eval` (Horner), and `ToString`. Then
   `npow (X + 1) 5` gives you binomial coefficients for free, because `Poly α` is a `Monoid`.

## Done when
`lake build Tests.P04Algebra` is green.

## Hints
* `class Monoid (α : Type) extends Mul α, One α`: an instance is *just* a `Mul` and a `One`.
  For `Nat`, `instance : Monoid Nat := {}` works because those instances already exist. For
  `String` you must provide `mul` and `one` fields.
* Sum over `Fin k`: `Fin.foldl k (fun acc l => acc + …) 0`. `Vector.ofFn` builds a vector from
  a function `Fin n → α`, and `v[i]` with `i : Fin n` needs no bounds proof.
* *Why not just store `entry : Fin m → Fin n → α`?* Try it. Lean is strict, but a closure
  isn't a table: every entry of `A * A` calls `A`'s entry function `k` times, recursively. With
  repeated squaring that blows up exponentially, so `fibFast 30` crawls. Storing data fixes it.
* For `npow` by squaring, recurse on `n / 2`. Lean then needs `termination_by n` and a proof that
  `n / 2 < n` when `n ≠ 0`. `omega` handles division by literals.
* Poly normal form: write `Poly.normalize` (drop trailing zeros) and call it in every
  operation that could create them. `deriving BEq` then means *polynomial equality*.

## Stretch
* `Matrix.transpose`, and a `ToString` that pretty-prints rows.
* A `mat[1, 2; 3, 4]` literal. You'll have the tools in P07.
* Make `Poly` work over `Matrix 2 2 Int`. Does it still make sense when `*` isn't commutative?
-/

namespace P04

class Monoid (α : Type) extends Mul α, One α

instance : Monoid Nat := sorry
instance : Monoid String := sorry

/-- `x ^ n` by repeated squaring, for any monoid. -/
def npow {α : Type} [Monoid α] (x : α) (n : Nat) : α := sorry

/-! ## Matrices with dimensions in the type -/

structure Matrix (m n : Nat) (α : Type) where
  rows : Vector (Vector α n) m

def Matrix.ofFn {m n : Nat} {α : Type} (f : Fin m → Fin n → α) : Matrix m n α := sorry
def Matrix.get {m n : Nat} {α : Type} (A : Matrix m n α) (i : Fin m) (j : Fin n) : α := sorry

def Matrix.identity (n : Nat) {α : Type} [Zero α] [One α] : Matrix n n α := sorry

instance {α : Type} {m k n : Nat} [Add α] [Mul α] [Zero α] :
    HMul (Matrix m k α) (Matrix k n α) (Matrix m n α) := sorry

instance {α : Type} {n : Nat} [Add α] [Mul α] [Zero α] [One α] : Monoid (Matrix n n α) := sorry

/-- Fibonacci via `npow` on 2×2 matrices: `fibFast 0 = 0`, `fibFast 1 = 1`, `fibFast 10 = 55`. -/
def fibFast (n : Nat) : Nat := sorry

/-! ## Polynomials -/

/-- Coefficients, lowest degree first, with no trailing zeros. -/
structure Poly (α : Type) where
  coeffs : List α
deriving BEq, Repr

section
variable {α : Type} [Add α] [Mul α] [Zero α] [One α] [BEq α]

def Poly.normalize (p : Poly α) : Poly α := sorry
def Poly.X : Poly α := sorry
def Poly.const (a : α) : Poly α := sorry
def Poly.eval (p : Poly α) (x : α) : α := sorry

instance : Add (Poly α) := sorry
instance : Mul (Poly α) := sorry
instance : Monoid (Poly α) := sorry
instance {n : Nat} [OfNat α n] : OfNat (Poly α) n := sorry
end

/-- Pretty-print with `x` as the variable, highest degree first, e.g. `"3x^2 + 2x + 1"`. Omit zero
terms, write `x` for `x^1`, and omit a coefficient of 1 (except on the constant term). The zero
polynomial prints as `"0"`. Negative coefficients may print as `+ -2x` (good enough). -/
instance {α : Type} [ToString α] [BEq α] [Zero α] [One α] : ToString (Poly α) := sorry

end P04
