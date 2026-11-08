/-!
# P01 · Kata — Lean with an OCaml accent

**Part I (programming)** · ~1 hour · builds on: nothing · reused by: **P11** (you will prove
theorems about *these exact functions*, so keep them simple).

## Why
Get the edit–check loop into your fingers before anything else. Everything here is something
you could write in OCaml in your sleep. The point is to learn how Lean *spells* it, and to get
used to the infoview, which shows the type and goal at your cursor.

## Setup (do this once)
* VS Code + the `lean4` extension. Open this folder, then open this file. The infoview should
  appear on the right.
* `lake build` builds every project. `lake build Tests.P01Kata` runs this project's acceptance
  tests. They stay red until you are done.

## You'll learn
`def` with equation-style pattern matching · `match` / `if` / `let` / `where` · `fun x => …`
and the `(· + 1)` shorthand · `|>` and `<|` · dot-notation (`xs.map f`, `xs.length`) ·
implicit arguments `{α : Type}` (and *auto-bound* implicits, which let you just write `α`) ·
instance arguments `[DecidableEq α]` · `#eval`, `#check`, `#print`, `#guard` ·
`termination_by` / `decreasing_by` (once, gently) · `partial def`.

## Tasks
Replace every `sorry`. Don't use the library function with the same purpose (`List.reverse`,
`List.getLast?`, …). Using other library functions is fine. Try each function with `#eval`
right below it as you go.

## Done when
`lake build Tests.P01Kata` is green and this file has no `sorry` warnings.

## Hints (OCaml / Rocq → Lean)
* `let rec f x = …` → `def f (x : τ) : σ := …`. Recursion needs no keyword.
* `function | [] -> … | x :: xs -> …` → `def f : List α → β | [] => … | x :: xs => …`
* `Some x` / `None` → `some x` / `none`. Write tuples `(a, b)` and project with `p.1`/`p.2` or `p.fst`.
* Pattern matching and `if` are expressions, just like OCaml.
* `[DecidableEq α]` lets you write `if x = y then …`. `[BEq α]` gives you `x == y : Bool`.
  This file uses `DecidableEq` on purpose: it makes P11's proofs nicer.
* Lean must see that every `def` terminates. Structural recursion is automatic. For `gcd'` you
  must say *what* decreases (`termination_by b`) and maybe *why* (`decreasing_by`). Look up
  `Nat.mod_lt`. If you can't prove termination, use `partial def`, but you then lose the ability to
  reason about the function (see `collatzSteps`).
* Lost? `#check @List.foldr` and `#print List.map`. Hover over anything, and Ctrl-click to jump to its definition.
-/

namespace P01

/-- Last element, if any. `last? [1,2,3] = some 3`. -/
def last? {α : Type} : List α → Option α := sorry

/-- 0-indexed element access. `kth? ['a','b'] 1 = some 'b'`, out of range → `none`. -/
def kth? {α : Type} : List α → Nat → Option α := sorry

/-- Reverse a list. The naive `rev xs ++ [x]` version is *fine* (and easier to prove in P11).
An accumulator version is faster, but you'll pay for it in P11. Your call! -/
def rev {α : Type} : List α → List α := sorry

/-- A palindrome reads the same backwards. -/
def isPalindrome {α : Type} [DecidableEq α] (xs : List α) : Bool := sorry

/-- Remove *consecutive* duplicates: `compress [1,1,2,1,1] = [1,2,1]`. -/
def compress {α : Type} [DecidableEq α] (ls: List α) : List α := sorry

/-- Group consecutive duplicates: `pack [1,1,2,1] = [[1,1],[2],[1]]`. -/
def pack {α : Type} [DecidableEq α] (ls: List α) : List (List α) := sorry

/-- Run-length encoding: `rle ['a','a','b'] = [('a',2),('b',1)]`.
Every count in the output is ≥ 1, and adjacent entries have different symbols. -/
def rle {α : Type} [DecidableEq α] (ls: List α) : List (α × Nat) := sorry

/-- Inverse of `rle`: `unrle [('a',2),('b',1)] = ['a','a','b']`. (Look at `List.replicate`.) -/
def unrle {α : Type} : List (α × Nat) → List α := sorry

/-- Inclusive ascending range: `range 3 6 = [3,4,5,6]`; empty when `lo > hi`. -/
def range (lo hi : Nat) : List Nat := sorry

/-- Primality by trial division. `isPrime 0 = isPrime 1 = false`.
Tip: if you build this from structurally recursive pieces (e.g. `List.range` + `List.all`),
`by decide` can evaluate it inside proofs (P11). Well-founded recursion blocks that. -/
def isPrime (n : Nat) : Bool := sorry

/-- Euclid's algorithm. You will need `termination_by` (and maybe `decreasing_by`). -/
def gcd' (a b : Nat) : Nat := sorry

/-- Goldbach: for even `n > 2`, return primes `(p, q)` with `p ≤ q`, `p + q = n`, and `p`
as small as possible. Return `none` when no such pair exists (e.g. odd `n`). -/
def goldbach? (n : Nat) : Option (Nat × Nat) := sorry

/-- Number of Collatz steps to reach 1 (`collatzSteps 1 = 0`, `collatzSteps 6 = 8`).
Nobody can prove this terminates, so mark it `partial def`. Then try `#print axioms` on it.
Treat `0` however you like; it is not tested. -/
partial def collatzSteps (n : Nat) : Nat := sorry

end P01
