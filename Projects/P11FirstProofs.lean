import Projects.P01Kata
/-!
# P11 · First proofs: theorems about *your* P01 code

**Part II (proofs)** · ~3 hours · builds on: **P01** (these theorems are about your
implementations) · reused by: everything after

## Why
You already know how to prove things in Rocq. This project is about relearning the *vocabulary*
(which tactic is called what, what `simp` does here, how goals display) on code you wrote
yourself. Some of these will be trivial. Some will be hard *because of how you implemented
P01*, and that's the second lesson: **write code that is easy to reason about**. If `rev`
uses an accumulator, `rev_rev` needs a generalized lemma first. Feel free to go back and
simplify P01, as long as its tests stay green.

## You'll learn
`theorem` / `example` · `by` blocks and the goal view in the infoview · `rfl`, `decide` ·
`simp`, `simp only [f]`, `simp [*]`, `simp at h`, `simp_all` · `rw [h]`, `rw [← h]` ·
`induction xs with | nil => … | cons x xs ih => …` · `cases h`, `rcases`/`obtain ⟨a, b⟩ := h` ·
`intro`, `exact`, `apply`, `constructor`, `exists` · `split` (case split on an `if`/`match`
in the goal. **Not** Rocq's `split`!) · `omega` (Rocq's `lia`) · `exact?` / `apply?` /
`simp?` / `rw?` to search the library · `have`, `show`, `calc` · term-mode proofs
(`fun h => ⟨h.2, h.1⟩`) · `#print axioms`.

## Rocq → Lean phrasebook
| Rocq | Lean 4 |
|---|---|
| `intros` / `intro` | `intro x y` (or `intros`) |
| `destruct x` / `inversion H` | `cases x` / `cases H` (or `rcases`, `obtain`) |
| `induction l as [|x l IH]` | `induction l with \| nil => … \| cons x l ih => …` |
| `simpl` / `unfold f` | `simp only [f]` / `unfold f` / `dsimp [f]` |
| `rewrite H` / `rewrite <- H` | `rw [H]` / `rw [← H]` |
| `reflexivity` | `rfl` |
| `split` (∧ goal) | `constructor` (and `refine ⟨?_, ?_⟩`) |
| `exists x` | `exists x` or `refine ⟨x, ?_⟩` |
| `lia` | `omega` |
| `auto` / `eauto` / `easy` | `simp_all`, `grind`, `trivial`, `decide` |
| `Search` | `exact?`, `apply?`, `#check @List.length_append`, and hovering |
| `Print Assumptions` | `#print axioms thm` |

## Done when
No `sorry` left in this file, and `lake build Tests.P11FirstProofs` is green. That build checks
that the theorems don't depend on `sorryAx`.

## Hints
* Equation lemmas: `simp [rev]` unfolds one step of `rev` by its defining equations. If you
  defined `rev` via `List.foldl` or a helper, you'll need lemmas about *that* instead.
* `List.replicate`, `List.length_append`, `List.append_assoc` and friends are `@[simp]`, so
  `simp` uses them automatically. Use `simp?` to see which ones fired.
* For `unrle_rle` you'll want to case on what the recursive call `rle xs` returned. Use
  `split` on the `match`, or `cases h : rle xs`.
* Work bottom-up. State helper lemmas as separate `theorem`s, and tag them `@[simp]` when they
  are good left-to-right rewrite rules.

## Stretch
* `compress (compress xs) = compress xs`.
* `(goldbach? n).isSome → n % 2 = 0`, and if `goldbach? n = some (p, q)` then `p + q = n`.
* State and prove "adjacent entries of `rle xs` have different symbols". Use your own inductive
  predicate, or state it over `(rle xs).zip (rle xs).tail`.
-/

namespace P11
open P01

section
variable {α : Type}

-- Warm-up: concrete facts. Try `rfl`, `decide`, and `by simp [rev]`. Which work, and why?
example : rev [1, 2, 3] = [3, 2, 1] := sorry
example : rle [1, 1, 2] = [(1, 2), (2, 1)] := sorry
example : isPrime 97 = true := sorry
example : kth? [10, 20, 30] 1 = some 20 := sorry

theorem rev_append (xs ys : List α) : rev (xs ++ ys) = rev ys ++ rev xs := sorry

theorem rev_rev (xs : List α) : rev (rev xs) = xs := sorry

theorem length_rev (xs : List α) : (rev xs).length = xs.length := sorry

/-- Your `rev` agrees with the library. -/
theorem rev_eq_reverse (xs : List α) : rev xs = xs.reverse := sorry

theorem last?_append_singleton (xs : List α) (x : α) : last? (xs ++ [x]) = some x := sorry

theorem kth?_eq_getElem? (xs : List α) (k : Nat) : kth? xs k = xs[k]? := sorry

theorem kth?_isSome_iff (xs : List α) (k : Nat) : (kth? xs k).isSome ↔ k < xs.length := sorry

theorem isPalindrome_append_rev [DecidableEq α] (xs : List α) :
    isPalindrome (xs ++ rev xs) = true := sorry

theorem length_compress_le [DecidableEq α] (xs : List α) :
    (compress xs).length ≤ xs.length := sorry

/-- The headline theorem: run-length decoding inverts encoding. -/
theorem unrle_rle [DecidableEq α] (xs : List α) : unrle (rle xs) = xs := sorry

theorem rle_counts_pos [DecidableEq α] (xs : List α) : ∀ p ∈ rle xs, 0 < p.2 := sorry

theorem length_range (lo hi : Nat) : (range lo hi).length = hi + 1 - lo := sorry

theorem mem_range {lo hi x : Nat} : x ∈ range lo hi ↔ lo ≤ x ∧ x ≤ hi := sorry

end

end P11
