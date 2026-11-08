import Projects.P10Sudoku
/-!
# P14 · Certified Sudoku: decidability, proof by computation, and proof-carrying results

**Part II** · ~4 hours · builds on: **P10** (your solver and checker) · reused by: P20
(`Decidable` instances from verified checkers)

## Why
Your P10 solver is fast, clever and unverified. Verifying the *search* would be a big job.
Instead you'll verify the much simpler *checker*, then wrap the solver so that every
answer it returns **carries a proof** that it's a valid solution of the given puzzle. Lean's
`Decidable` machinery also lets the type checker *run* your checker to prove theorems like
"this grid is a solution" with `by decide`. That's proof by computation, a close relative of
Rocq's `vm_compute; reflexivity`.

## You'll learn
`Prop` vs `Bool` and the bridge between them: `Decidable p`, `decide p`, `decide_eq_true_iff` ·
writing `Decidable`/`DecidablePred` instances (`inferInstanceAs`, `decidable_of_iff`, unfolding
to bounded quantifiers) · `by decide` vs `by decide +kernel` vs `by native_decide`, and **what
each one trusts** (`#print axioms` shows `Lean.ofReduceBool` for the last one) · subtypes
`{s : Board // P s}` as return types · the dependent `if h : p then … else …` ·
`List.all_eq_true`, `List.any_eq_true` and friends for Bool ↔ ∀/∃ · proving *your P10
function* equivalent to a spec.

## Tasks
1. `DecidablePred Solved` and `DecidablePred (Agrees p)`.
2. `euler1_certified` and `euler1_not_solved` by computation. Try `decide`, `decide +kernel`
   and `native_decide`, time them, and `#print axioms` each.
3. `isValidSolution_iff`: your P10 checker is *exactly* `Solved`. The spec's `unitSpec`
   is written independently of your `units` table, so first show they agree. If the orders
   match, `decide +kernel` proves `units = (unitSpec.map List.toArray).toArray`. Plain
   `decide` may get stuck, depending on how you built `units`.
4. `agreesB` + `agreesB_iff`, then `certify` and `solveCertified`. Soundness is now *in the type*.

## Done when
No `sorry` in this file, and `lake build Tests.P14Certified` is green.

## Hints
* `∀ d, 1 ≤ d → d ≤ 9 → …` is not obviously decidable. Prove it equivalent to
  `∀ d ∈ List.range' 1 9, …` and use `decidable_of_iff`. Or write `Solved` that way from the
  start in a private helper and show the two agree.
* If your P10 `isValidSolution` turned out clever (bit tricks), simplify it. The P10 tests
  keep you honest. Simple checker, clever solver.
* `decide` gives up when a definition uses well-founded recursion. Kernel reduction
  (`decide +kernel`) is more patient.

## Stretch
* Completeness of `solveCertified` can't be proved without verifying the search. Prove the
  weaker "if the puzzle has at most one solution and `solve` finds *a* solution, it is *the* solution".
* Make P10's `main` use `solveCertified` and print "✓ certified" per puzzle.
-/

namespace P14
open P10

/-- Rows, then columns, then boxes, each in increasing index order. Written independently of
P10 so that the spec doesn't trust the implementation. -/
def unitSpec : List (List (Fin 81)) :=
  (List.finRange 9).map (fun r => (List.finRange 9).map fun c => ⟨r * 9 + c, by omega⟩) ++
  (List.finRange 9).map (fun c => (List.finRange 9).map fun r => ⟨r * 9 + c, by omega⟩) ++
  (List.finRange 9).map (fun b => (List.finRange 9).map fun k =>
    ⟨(b / 3 * 3 + k / 3) * 9 + b % 3 * 3 + k % 3, by omega⟩)

/-- Every unit contains every digit 1–9. (That forces all cells to be 1–9 *and* distinct per unit.) -/
def Solved (b : Board) : Prop :=
  ∀ u ∈ unitSpec, ∀ d, 1 ≤ d → d ≤ 9 → ∃ i ∈ u, b[i] = d

/-- The solution keeps every given clue of the puzzle. -/
def Agrees (puzzle sol : Board) : Prop :=
  ∀ i : Fin 81, puzzle[i] ≠ 0 → sol[i] = puzzle[i]

instance : DecidablePred Solved := sorry
instance (p : Board) : DecidablePred (Agrees p) := sorry

def euler1 : Board := #v[0,0,3,0,2,0,6,0,0, 9,0,0,3,0,5,0,0,1, 0,0,1,8,0,6,4,0,0,
                         0,0,8,1,0,2,9,0,0, 7,0,0,0,0,0,0,0,8, 0,0,6,7,0,8,2,0,0,
                         0,0,2,6,0,9,5,0,0, 8,0,0,2,0,3,0,0,9, 0,0,5,0,1,0,3,0,0]
def euler1Sol : Board := #v[4,8,3,9,2,1,6,5,7, 9,6,7,3,4,5,8,2,1, 2,5,1,8,7,6,4,9,3,
                            5,4,8,1,3,2,9,7,6, 7,2,9,5,6,4,1,3,8, 1,3,6,7,9,8,2,4,5,
                            3,7,2,6,8,9,5,1,4, 8,1,4,2,5,3,7,6,9, 6,9,5,4,1,7,3,8,2]

theorem euler1_certified : Solved euler1Sol ∧ Agrees euler1 euler1Sol := sorry

theorem euler1_not_solved : ¬ Solved euler1 := sorry

/-- Your P10 checker decides exactly the spec. -/
theorem isValidSolution_iff (b : Board) : isValidSolution b = true ↔ Solved b := sorry

def agreesB (puzzle sol : Board) : Bool := sorry

theorem agreesB_iff (puzzle sol : Board) : agreesB puzzle sol = true ↔ Agrees puzzle sol := sorry

/-- Check a candidate at runtime (with the fast Bool checkers) and package the proof. -/
def certify (puzzle sol : Board) : Option {s : Board // Solved s ∧ Agrees puzzle s} := sorry

def solveCertified (puzzle : Board) : Option {s : Board // Solved s ∧ Agrees puzzle s} := sorry

end P14
