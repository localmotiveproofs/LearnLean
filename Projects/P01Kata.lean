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
def last? {α : Type} : List α → Option α
  | [] => none
  | [x] => some x
  | _ :: xs => last? xs

/-- 0-indexed element access. `kth? ['a','b'] 1 = some 'b'`, out of range → `none`. -/
def kth? {α : Type} : List α → Nat → Option α
  | [], _ => none
  | x :: _, 0 => some x
  | _ :: xs, j + 1 => kth? xs j

/-- Reverse a list. The naive `rev xs ++ [x]` version is *fine* (and easier to prove in P11).
An accumulator version is faster, but you'll pay for it in P11. Your call! -/
def rev {α : Type} : List α → List α := by
  intro xs
  exact match xs with
  | [] => []
  | x :: xs => rev xs ++ [x]

/-- A palindrome reads the same backwards. -/
def isPalindrome {α : Type} [DecidableEq α] (xs : List α) : Bool :=
  let reversed := rev xs
  reversed == xs

/-- Remove *consecutive* duplicates: `compress [1,1,2,1,1] = [1,2,1]`. -/
def compress {α : Type} [DecidableEq α] (ls: List α) : List α :=
  let rec aux (ls : List α) (elt_o: Option α) :=
    match ls, elt_o with
    | a :: t, some b =>
      if a == b then aux t a else a :: aux t a
    | a :: t, none => a :: aux t a
    | [], _ => []
  aux ls none

/-- Group consecutive duplicates: `pack [1,1,2,1] = [[1,1],[2],[1]]`. -/
def pack {α : Type} [DecidableEq α] (ls: List α) : List (List α) :=
  let rec aux (ls: List α) (acc: List α) : List (List α) :=
    match ls, acc with
    | a :: t, l =>
      match l with
      | a' :: _ =>
        if a' == a then aux t (a :: l) else l :: (aux t [ a ])
      | [] =>
        aux t [a]
    | [], [] => []
    | [], l => [ l ]
  aux ls []

/-- Run-length encoding: `rle ['a','a','b'] = [('a',2),('b',1)]`.
Every count in the output is ≥ 1, and adjacent entries have different symbols. -/
def rle {α : Type} [DecidableEq α] (ls: List α) : List (α × Nat) :=
  let packed := pack ls
  List.filterMap (fun
  | [] => none
  | x :: xs => (x, 1 + xs.length)) packed

/-- Inverse of `rle`: `unrle [('a',2),('b',1)] = ['a','a','b']`. (Look at `List.replicate`.) -/
def unrle {α : Type} : List (α × Nat) → List α
  | [] => []
  | (a, k) :: t =>
    let rec gen (alph: α) (x: Nat) :=
      if x <= 0 then [] else alph :: (gen alph (x - 1))
    (gen a k) ++ unrle t

/-- Inclusive ascending range: `range 3 6 = [3,4,5,6]`; empty when `lo > hi`. -/
def range (lo hi : Nat) : List Nat :=
  if lo > hi then [] else
  let rec aux lo i :=
    match i with
    | 0 => [ lo ]
    | j + 1 => (lo + i) :: (aux lo j)
  rev (aux lo (hi - lo))


/-- Primality by trial division. `isPrime 0 = isPrime 1 = false`.
Tip: if you build this from structurally recursive pieces (e.g. `List.range` + `List.all`),
`by decide` can evaluate it inside proofs (P11). Well-founded recursion blocks that. -/
def isPrime (n : Nat) : Bool :=
  if n <= 1 then false
  else
    let trials := range 2 (n - 1)
    ¬ (trials.any (fun x => n % x == 0))


/-- Euclid's algorithm. You will need `termination_by` (and maybe `decreasing_by`). -/
def gcd' (a b : Nat) : Nat :=
  if b = 0 then a else gcd' b (a % b)
    termination_by b
    decreasing_by exact Nat.mod_lt _ (by omega)

/-- Goldbach: for even `n > 2`, return primes `(p, q)` with `p ≤ q`, `p + q = n`, and `p`
as small as possible. Return `none` when no such pair exists (e.g. odd `n`). -/
def goldbach? (n : Nat) : Option (Nat × Nat) :=
  if n % 2 != 0 then none else
    let ranges := range 1 n
    let primes_ranges := List.filter isPrime ranges
    let aux p :=
      n - p ≥ p && isPrime (n - p)
    let goldbach_pairs := List.filter aux primes_ranges
    match goldbach_pairs with
    | a :: _ => some (a, n - a)
    | _ => none

/-- Number of Collatz steps to reach 1 (`collatzSteps 1 = 0`, `collatzSteps 6 = 8`).
Nobody can prove this terminates, so mark it `partial def`. Then try `#print axioms` on it.
Treat `0` however you like; it is not tested. -/
partial def collatzSteps (n : Nat) : Nat :=
  match n, n % 2 with
  | 1, _ => 0
  | _, 0  => 1 + collatzSteps (n / 2)
  | _, _ => 1 + collatzSteps (n * 3 + 1)


end P01
