/-!
# P15 · A verified binary search tree map, with invariants bundled into a type

**Part II** · ~5 hours · builds on: P13 (`Pairwise`, sortedness) · reused by: —

## Why
Data-structure invariants are where proofs and programs meet day to day. You'll prove that
`insert` preserves the BST invariant, connect lookups to the in-order traversal, and then
**bundle** the invariant into a structure (`TreeMap`), so that users of the API can't build
an invalid tree. That's how core's `Std.TreeMap` is designed. You'll also prove the classic
**abstraction-function** theorem: a map behaves like a function `Nat → Option α`.

## You'll learn
predicates defined by recursion (`ForallKeys`) vs inductively (`BST`), and when each is
nicer · `cases h` / `rcases h with ⟨…⟩` on inductive hypotheses · `split` on `if`/`match` with
`compare`, `Nat.lt_trichotomy` · `simp` with your own `@[simp]` lemmas · `grind`, Lean's
SMT-style automation, which shines on exactly this kind of case-heavy reasoning. Prove a few
lemmas by hand first, then see how many `grind` closes outright · `structure` with a proof
field · subtype-style APIs where every operation must re-establish the invariant.

## Tasks
1. `find?`, `insert`, `toList` (in-order).
2. The lemma ladder: `find?_insert_self`, `find?_insert_ne`, `forallKeys_insert`,
   `insert_BST`, `toList_sorted`, `find?_eq_some_iff_mem`.
3. `TreeMap`: `empty`, `insert`, `find?`, `toList`, `ofList`, and `TreeMap.find?_insert`.

## Done when
No `sorry` in this file, and `lake build Tests.P15SearchTree` is green.

## Hints
* Two of the theorems *don't need* the BST invariant. Notice which, and why.
* A helper you'll want for `find?_eq_some_iff_mem` and `toList_sorted`:
  `ForallKeys p t ↔ ∀ kv ∈ t.toList, p kv.1`.
* `insert` via `if k < k' then … else if k' < k then … else …` gives `omega`-friendly cases.
  Via `compare` you'll need `Nat.compare_eq_lt` & co.

## Stretch
* `erase` (replace the node by the minimum of its right subtree), with `erase_BST` and
  `find?_erase`. A real step up in difficulty.
* Balance it: AVL or red-black insertion, proving the BST invariant (balance is a separate,
  harder invariant).
* Generalize keys to any `α` with `[Ord α]` and a lawful-ordering class.
-/

namespace P15

inductive Tree (α : Type) where
  | leaf
  | node (l : Tree α) (key : Nat) (val : α) (r : Tree α)
deriving Repr

namespace Tree
variable {α : Type}

def find? : Tree α → Nat → Option α := sorry

def insert : Tree α → Nat → α → Tree α := sorry

/-- In-order traversal. -/
def toList : Tree α → List (Nat × α) := sorry

/-- Every key in the tree satisfies `p`. -/
def ForallKeys (p : Nat → Prop) : Tree α → Prop
  | leaf => True
  | node l k _ r => ForallKeys p l ∧ p k ∧ ForallKeys p r

inductive BST : Tree α → Prop where
  | leaf : BST leaf
  | node {l : Tree α} {k : Nat} {v : α} {r : Tree α} :
      ForallKeys (· < k) l → ForallKeys (k < ·) r → BST l → BST r → BST (node l k v r)

theorem find?_insert_self (t : Tree α) (k : Nat) (v : α) : (t.insert k v).find? k = some v := sorry

theorem find?_insert_ne (t : Tree α) {k k' : Nat} (v : α) (h : k ≠ k') :
    (t.insert k v).find? k' = t.find? k' := sorry

theorem forallKeys_insert {p : Nat → Prop} {t : Tree α} {k : Nat} {v : α} :
    ForallKeys p t → p k → ForallKeys p (t.insert k v) := sorry

theorem insert_BST {t : Tree α} (k : Nat) (v : α) : BST t → BST (t.insert k v) := sorry

theorem toList_sorted {t : Tree α} : BST t → (t.toList.map Prod.fst).Pairwise (· < ·) := sorry

theorem find?_eq_some_iff_mem {t : Tree α} (h : BST t) (k : Nat) (v : α) :
    t.find? k = some v ↔ (k, v) ∈ t.toList := sorry

end Tree

/-! ## The bundled API -/

structure TreeMap (α : Type) where
  tree : Tree α
  bst  : tree.BST

namespace TreeMap
variable {α : Type}

def empty : TreeMap α := sorry
def insert (m : TreeMap α) (k : Nat) (v : α) : TreeMap α := sorry
def find? (m : TreeMap α) (k : Nat) : Option α := sorry
def toList (m : TreeMap α) : List (Nat × α) := sorry
/-- Later entries win. -/
def ofList (kvs : List (Nat × α)) : TreeMap α := sorry

/-- The abstraction function: a `TreeMap` behaves like a partial function `Nat → Option α`. -/
theorem find?_insert (m : TreeMap α) (k k' : Nat) (v : α) :
    (m.insert k v).find? k' = if k' = k then some v else m.find? k' := sorry

theorem find?_empty (k : Nat) : (empty : TreeMap α).find? k = none := sorry

end TreeMap

end P15
