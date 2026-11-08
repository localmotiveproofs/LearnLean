import Projects.P06Json
/-!
# P20 · Capstone: `vgrep`, a regex search tool with a *verified* matching engine

**Part II** · ~8 hours · builds on: **P06** (parser combinators), **P07** (macros),
**P13–P14** (inductive predicates, `Decidable` from a verified checker), P02 (CLI)

## Why
Everything comes together here: a real command-line tool, written in Lean, whose core
algorithm is **proved** to implement the textbook semantics of regular expressions. The
engine uses Brzozowski derivatives: `deriv c r` matches exactly the words `w` such that `r`
matches `c :: w`. It's short, elegant and executable, and its correctness proof has one
genuinely tricky case (`star`). That's a fitting final boss for someone who knows Rocq.

## The tool
```
lake exe vgrep PATTERN [FILE ...]      # stdin if no files
```
Prints every line containing a match, prefixed with `file:lineno:` when there are several files.
Exit status: `0` if any line matched, `1` if none did, `2` on a bad pattern or unreadable file.

## Pattern syntax
```
alt    ::= seq ('|' seq)*          -- lowest precedence; an empty seq means ε (so "a|" matches "")
seq    ::= repeat*                 -- concatenation
repeat ::= atom ('*' | '+' | '?')*
atom   ::= '(' alt ')' | '.' | '\' anychar | any char except  ( ) | * + ? . \
```
`r+` means `r r*` and `r?` means `ε | r`. `.` matches any single character.

## You'll learn
The whole toolbox, used together: inductive predicates with tricky inversion (`generalize` an
index before `induction`) · a proof that needs an auxiliary *inversion lemma* proved by its
own induction on a derivation · `decidable_of_iff` to turn a verified Bool function into a
`Decidable` instance, so `by decide` works on `Matches` · reusing your P06 `Parser` for a
precedence grammar · a polished CLI.

## Tasks
1. `nullable`, `deriv`, `matchD` (specified in their docstrings).
2. `nullable_iff`, then `deriv_iff` (the heart), then `matchD_iff`, then the `Decidable` instance.
3. `parseRegex`, `Regex.containsMatch` (substring search: does `.*r.*` match?), and `main`.

## Done when
No `sorry` in this file, `lake build Tests.P20Regex` is green, and
`lake exe vgrep 'theorem [a-z_]+' Projects/*.lean` works. (Character classes `[a-z]` are a
stretch goal, so until then use `theorem (a|b|c|…)+`!)

## Hints
* `cases h` on `h : Matches (.cat r s) w` works when `w` is a *variable*. For a concrete index
  like `[]` or `c :: w`, first prove an inversion lemma
  `Matches (.cat r s) w → ∃ u v, w = u ++ v ∧ Matches r u ∧ Matches s v`.
* The `star` case of `deriv_iff` (right to left) needs
  `star_cons_inv : Matches (.star r) (c :: w) → ∃ u v, w = u ++ v ∧ Matches r (c :: u) ∧ Matches (.star r) v`.
  Prove it by induction on the derivation, after `generalize hx : Regex.star r = x at h` and
  `generalize hw : c :: w = w' at h`. When the first iteration matched `[]`, the IH does the job.
* `deriv_iff`: induction on `r` *generalizing `w`*.
* `List.append_eq_nil_iff`, `List.cons_eq_append_iff` and `List.cons.injEq` will come up.

## Stretch
* Character classes `[a-z0-9_]` (add a `Regex.set` constructor and update the proofs).
* Smart constructors that simplify `∅·r = ∅`, `ε·r = r`, `∅|r = r` and so on. Prove each one
  preserves `Matches`, and show `matchD` with them is still correct. Then measure the speed-up
  on `(a|aa)*b` against `aaaa…a`.
* A `re%"(ab)*c"` term macro (P07) that parses the pattern *at compile time*.
* Memoize derivatives up to similarity to build a DFA (Brzozowski's construction).
-/

namespace P20

inductive Regex where
  | empty
  | eps
  | chr (c : Char)
  | any
  | cat (r s : Regex)
  | alt (r s : Regex)
  | star (r : Regex)
deriving Repr, DecidableEq

/-- The textbook semantics. -/
inductive Matches : Regex → List Char → Prop where
  | eps : Matches .eps []
  | chr (c : Char) : Matches (.chr c) [c]
  | any (c : Char) : Matches .any [c]
  | cat {r s : Regex} {u v : List Char} : Matches r u → Matches s v → Matches (.cat r s) (u ++ v)
  | altL {r s : Regex} {w : List Char} : Matches r w → Matches (.alt r s) w
  | altR {r s : Regex} {w : List Char} : Matches s w → Matches (.alt r s) w
  | starNil {r : Regex} : Matches (.star r) []
  | starCons {r : Regex} {u v : List Char} :
      Matches r u → Matches (.star r) v → Matches (.star r) (u ++ v)

/-- Does `r` accept the empty word? (Structural recursion, no `Matches` involved.) -/
def nullable : Regex → Bool := sorry

/-- The Brzozowski derivative. For `cat r s`: if `r` is nullable, also try `deriv c s`.
For `star r`: `cat (deriv c r) (star r)`. -/
def deriv (c : Char) : Regex → Regex := sorry

/-- Take derivatives along the word, then ask `nullable`. -/
def matchD (r : Regex) : List Char → Bool := sorry

theorem nullable_iff (r : Regex) : nullable r = true ↔ Matches r [] := sorry

theorem deriv_iff (c : Char) (r : Regex) (w : List Char) :
    Matches (deriv c r) w ↔ Matches r (c :: w) := sorry

theorem matchD_iff (r : Regex) (w : List Char) : matchD r w = true ↔ Matches r w := sorry

instance (r : Regex) (w : List Char) : Decidable (Matches r w) := sorry

/-! ## The tool -/

def parseRegex (s : String) : Except String Regex := sorry

/-- Does some substring of `s` match `r`? -/
def Regex.containsMatch (r : Regex) (s : String) : Bool := sorry

def main (args : List String) : IO UInt32 := do
  IO.eprintln s!"P20: not implemented yet (args = {args})"
  return 2

end P20
