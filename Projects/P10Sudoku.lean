/-!
# P10 · A fast Sudoku solver: arrays, in-place mutation, bitsets, and parallelism

**Part I** · ~5 hours · builds on: P05 · reused by: **P14** (you'll certify its output
with proofs)

## Why
Lean is a *compiled* language with a reference-counted runtime. When an array's reference
count is 1, `set` mutates it **in place**, so pure code runs like imperative code. This is
"functional but in-place" (FBIP). This project makes you feel it: an accidental extra
reference turns an O(1) update into an O(n) copy, and you'll learn to spot that. You'll also
use `Fin`-indexed `Vector`s, which give bounds-safe indexing for free, and `Task`s for
parallelism.

## The tool
```
lake exe sudoku FILE [--threads N]     # one puzzle per line (81 chars, '.' or '0' = empty)
```
Prints each solution as an 81-char line (or `no solution`), then a summary like
`solved 200/200 in 412 ms with 8 threads`. Validates every answer with `isValidSolution`.
Try `data/sudoku/easy.txt`, `hard.txt`, `many.txt`.

## You'll learn
`Vector α n` (core's array-with-length) and `b[i]` with `i : Fin 81`, so no proofs are needed ·
precomputed lookup tables as top-level `def`s (computed once) · `UInt16` bitsets
(`&&&`, `|||`, `<<<`, `~~~`, counting bits) · `@[inline]` / `@[specialize]` · `partial def`
for search (or a `fuel` argument) · `dbgTraceIfShared` to *catch* accidental copies ·
`Task.spawn` / `IO.asTask` + `IO.wait` · `IO.monoMsNow` · compiled (`lake exe`) vs `#eval` speed.

## Tasks
1. `parseBoard`, `Board.toLine`, `Board.render`.
2. `units` (27 rows/cols/boxes) and `peers` (the 20 cells sharing a unit with each cell).
3. `isValidSolution`. Keep it **simple and obviously correct**: P14 will *prove* it equivalent
   to a mathematical spec, so cleverness here is a liability. (The checker is simple, the
   solver can be clever. That's the de Bruijn criterion.)
4. `solve`: backtracking over candidate bitmasks, picking the empty cell with the *fewest*
   candidates first (MRV). It must return `none` for inconsistent givens.
5. `solveAll` with `--threads N` parallelism, and `main`.

## Done when
`lake build Tests.P10Sudoku` is green, and `lake exe sudoku data/sudoku/hard.txt` solves every
puzzle in well under a second each. Then put a `dbgTraceIfShared` on the board update in
your hot loop and check that it never fires.

## Hints
* `Vector.set b i v` with `i : Fin 81` needs no proof. `Vector.ofFn` builds tables.
* State for search: the board plus a `Vector UInt16 81` of candidate masks, or recompute
  candidates from row/col/box masks (three `Vector UInt16 9`s). The second approach is simpler
  and fast.
* If you can't convince Lean that `solve` terminates, `partial def` is perfectly fine here.
  P14 doesn't need to reason *about* `solve`, only about its *output*.
* Generating many puzzles is CPU-bound, so threads help. `Task.spawn` runs a pure function;
  `IO.asTask` runs an `IO` action.

## Stretch
* Naked/hidden singles propagation before branching; measure the speed-up on `hard.txt`.
* `sudoku --count` to count solutions (to detect non-unique puzzles).
-/

namespace P10

/-- Row-major, 0 = empty, 1–9 = digit. -/
abbrev Board := Vector Nat 81

/-- 81 cells from `1-9`, with `0` or `.` for empty; whitespace is ignored; anything else → `none`. -/
def parseBoard (s : String) : Option Board := sorry

/-- 81 characters, `.` for empty cells. -/
def Board.toLine (b : Board) : String := sorry

/-- A human-friendly 9×9 grid with box separators (format up to you; not tested). -/
def Board.render (b : Board) : String := sorry

def rowOf (i : Fin 81) : Fin 9 := sorry
def colOf (i : Fin 81) : Fin 9 := sorry
def boxOf (i : Fin 81) : Fin 9 := sorry

/-- The 27 units: 9 rows, 9 columns, 9 boxes (in that order, boxes left-to-right then
top-to-bottom), each listing its 9 cells in increasing index order. P14 relies on this order. -/
def units : Array (Array (Fin 81)) := sorry

/-- The 20 cells that share a row, column or box with `i` (excluding `i` itself). -/
def peers (i : Fin 81) : Array (Fin 81) := sorry

/-- Complete (all cells 1–9) and every unit contains each digit 1–9. -/
def isValidSolution (b : Board) : Bool := sorry

/-- A solution extending `b`, or `none` if there is none. -/
def solve (b : Board) : Option Board := sorry

/-- Solve all puzzles using up to `threads` parallel tasks. Results in input order. -/
def solveAll (puzzles : Array Board) (threads : Nat) : IO (Array (Option Board)) := sorry

def main (args : List String) : IO UInt32 := do
  IO.eprintln s!"P10: not implemented yet (args = {args})"
  return 1

end P10
