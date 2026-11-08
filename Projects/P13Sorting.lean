/-!
# P13 · Verified sorting: inductive predicates, permutations, well-founded recursion, `@[csimp]`

**Part II** · ~5 hours · builds on: P11, P12 · reused by: P15 (sortedness of tree
traversals), P19 (sorting atoms in the commutative normalizer)

## Why
Sorting is where "correct" stops being obvious. You need *two* properties (sorted **and** a
permutation), a recursion that isn't structural (merge sort), and a uniqueness lemma that
ties two algorithms together. The payoff at the end is a Lean-specific trick: `@[csimp]` swaps
the slow, easily verified insertion sort for merge sort **in compiled code**, and it's
justified by your theorem.

## You'll learn
inductive predicates (`Sorted`) and choosing between formulations (`Sorted` vs
`List.Pairwise (· ≤ ·)`) · `List.Perm` (`l₁ ~ l₂`) and its API: `Perm.cons`, `Perm.trans`,
`Perm.swap`, `perm_middle`, `Perm.mem_iff`, `Perm.cons_inv` · `termination_by` /
`decreasing_by` for merge sort · **functional induction** (`fun_induction msort l`): induction
that follows your function's own recursion, IHs included · `grind` as a power tool (do a few
proofs by hand first!) · `@[csimp]`.

## Tasks
1. `insert`/`isort` and their four lemmas.
2. `merge`/`msort`. Pick a splitting strategy. `l.take (l.length / 2)` / `drop` makes the
   termination and permutation proofs easy (`List.take_append_drop`). Alternating split is
   more fun.
3. `sorted_perm_eq`, the uniqueness of sorted permutations, and then `msort_eq_isort` as a corollary.
4. `@[csimp] theorem isort_eq_msort : @isort = @msort`. Then `#eval (isort (List.range 100000).reverse).length`
   runs instantly. Remove the attribute and try it with `20000`: it crawls, because that's
   insertion sort on a reversed list.

## Done when
No `sorry` in this file, and `lake build Tests.P13Sorting` is green.

## Hints
* Prove `sorted_iff_pairwise : Sorted l ↔ l.Pairwise (· ≤ ·)` early. Core has plenty of
  `List.pairwise_*` simp lemmas, and `merge_sorted` is much nicer in `Pairwise` form.
* `merge` recurses on *both* lists, so Lean infers termination via a lexicographic or sum
  measure. If not, `termination_by xs.length + ys.length`.
* For `merge` lemmas, `fun_induction merge xs ys` gives exactly the three cases you want.
* `sorted_perm_eq`: induction on `l₁` generalizing `l₂`. The heads must be equal by
  antisymmetry of `≤`, then use `Perm.cons_inv`.

## Stretch
* Generalize to any `α` with a total order. Define your own class with the laws you need, or
  use core's `Ord` plus the `Std.TransCmp` / `Std.OrientedCmp` / `Std.LawfulEqCmp` law classes.
* Stability: sort pairs by key and prove equal keys keep their relative order.
* **Back to P03:** prove your Huffman `decode t (encode t xs) = some xs` when every symbol of
  `xs` is in `t`.
-/

namespace P13

inductive Sorted : List Nat → Prop where
  | nil : Sorted []
  | single (x : Nat) : Sorted [x]
  | cons {x y : Nat} {rest : List Nat} : x ≤ y → Sorted (y :: rest) → Sorted (x :: y :: rest)

/-- Insert into an (assumed) sorted list. -/
def insert (x : Nat) : List Nat → List Nat := sorry

def isort : List Nat → List Nat := sorry

theorem insert_perm (x : Nat) (l : List Nat) : (insert x l).Perm (x :: l) := sorry

theorem insert_sorted {x : Nat} {l : List Nat} : Sorted l → Sorted (insert x l) := sorry

theorem isort_perm (l : List Nat) : (isort l).Perm l := sorry

theorem isort_sorted (l : List Nat) : Sorted (isort l) := sorry

/-! ## Merge sort -/

def merge : List Nat → List Nat → List Nat := sorry

def msort (l : List Nat) : List Nat := sorry

theorem merge_perm (xs ys : List Nat) : (merge xs ys).Perm (xs ++ ys) := sorry

theorem merge_sorted {xs ys : List Nat} : Sorted xs → Sorted ys → Sorted (merge xs ys) := sorry

theorem msort_perm (l : List Nat) : (msort l).Perm l := sorry

theorem msort_sorted (l : List Nat) : Sorted (msort l) := sorry

/-! ## Uniqueness, and swapping implementations -/

theorem sorted_perm_eq {l₁ l₂ : List Nat} : Sorted l₁ → Sorted l₂ → l₁.Perm l₂ → l₁ = l₂ := sorry

theorem msort_eq_isort (l : List Nat) : msort l = isort l := sorry

/-- Add `@[csimp]` once proved: compiled calls to `isort` then run `msort`. -/
theorem isort_eq_msort : @isort = @msort := sorry

end P13
