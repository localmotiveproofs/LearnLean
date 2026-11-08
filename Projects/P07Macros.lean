import Projects.P06Json
/-!
# P07 · The macro system: notation, embedded DSLs, and code-generating commands

**Part I** · ~4 hours · builds on: P06 (the `JSON` type) · reused by: P08 (optional
`while%` literals), **P18** (tactic macros use the same machinery), P20 (`re%` literals)

## Why
Lean's syntax is user-extensible *all the way down*. `if`, `do` and `for` are themselves just
`syntax` + macros in core. This is the feature that most separates Lean from OCaml or Rocq, so
it gets a whole project. You'll stay at the **macro** level (`Syntax → Syntax` rewriting).
Elaborators that inspect *types* wait until P18.

## You'll learn
`notation` / `infixl` with precedences · `macro` for one-off term macros · `syntax` + `macro_rules`
for multi-case and recursive macros · `declare_syntax_cat` for an embedded language ·
quotations `` `(…) `` and antiquotations `$x`, `$x:ident`, sequences `$xs,*` and `$[…]*` ·
**hygiene** (and stepping around it on purpose with `mkIdent`) · command macros that generate
several declarations · `Syntax.mkStrLit`, `TSyntax.getElems`, `Name` concatenation · debugging
expansions (hover over syntax, `set_option trace.Elab.step true`).

## Tasks (all exercised by `Tests/P07Macros.lean`)
1. **Mixfix notation:** `a ≡ b [MOD n]` meaning `a % n = b % n`, at precedence 50.
2. **Hygiene:** `twice! e` expanding to `let x := e; x + x`. Check that
   `let x := 10; twice! (x + 1)` is `22`. Then explain to yourself *why* it isn't `20` or `11`.
3. **`json%` literals** for P06's `JSON`: `null`, `true`, `false`, strings, (negative) integer
   numerals, arrays, objects with string keys, and `(term)` to splice in any Lean term of type
   `JSON`. Use a syntax category `json`.
4. **List comprehensions:** `[e | x ← xs, y ← ys, if p]` (any mix and number of generators and
   guards), desugaring to `List.flatMap` and `if`. It mustn't break ordinary list literals.
5. **`enum Color { red, green, blue }`** must generate `inductive Color` (deriving `Repr`,
   `DecidableEq`), plus `Color.all : List Color` and a `ToString Color` instance printing the
   constructor names.
6. **`#expect a == b`**: a command that does nothing if `a == b`, and otherwise fails with
   `expected <repr b>, got <repr a>`.

## Done when
`lake build Tests.P07Macros` is green.

## Hints
* Start every macro by writing the *expansion* by hand and checking that it elaborates.
* For keywords like `null`/`true` inside your category, declare it with
  `declare_syntax_cat json (behavior := symbol)`. Otherwise `null` becomes a reserved word
  everywhere.
* A macro can run code in `MacroM` before building syntax:
  `macro_rules | `(…) => do let xs ← …; `(…)`.
* Generating several commands: return `mkNullNode #[cmd₁, cmd₂, …]`.
* To *create* a name the user can refer to, like `Color.all`, use `mkIdent`. Plain quotation
  would make the name hygienic, so the user couldn't refer to it.
* Core Lean has its own `json%` (in `Lean.Data.Json.Elab`). Read it *after* you're done and
  compare. That's also why this file doesn't `import Lean`.

## Stretch
* `json%` with decimal numbers (`scientific` literals) and bare identifiers as keys.
* `mat%[1, 2; 3, 4]` building a `P04.Matrix 2 2 _`. The macro has to count rows and columns.
* An `elab` version of `#expect` that shows the *source text* of `a` in the error
  (preview of P18).
-/

namespace P07
open P06

/-! ## Worked example: a variadic `max!(a, b, c)` -/

syntax "max!" "(" term,+ ")" : term
macro_rules
  | `(max!($x)) => `($x)
  | `(max!($x, $xs,*)) => `(max $x (max!($xs,*)))

#guard max!(3, 7, 2) == 7

/-! ## Your macros go here (they must be visible from `Tests/P07Macros.lean`) -/

end P07
