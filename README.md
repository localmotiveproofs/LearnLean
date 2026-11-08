# Learn Lean 4 in 20 projects

A hands-on curriculum for someone who already knows **OCaml, Scala and Rocq**. It skips what
you already know (ADTs, pattern matching, "what is a dependent type") and spends your time on
what's *specific to Lean*: its syntax and `do`-notation, typeclass-driven notation, the
reference-counted runtime, the macro system, programming with dependent types, the tactic
language, and metaprogramming in Lean itself.

* **Part I (P01–P10): programming.** Ten real programs: CLIs, a compressor, a ray tracer, a
  JSON tool, an interpreter, a Sudoku solver. Macros and dependent types are introduced gently along the way.
* **Part II (P11–P20): proofs, introduced incrementally.** Each project adds one or two proof
  techniques, and most of them **prove things about code you wrote in Part I**.

Everything uses **core Lean 4.35 + `Std` only (no Mathlib)**, so builds take seconds.

---

## Quick start

```bash
# toolchain (already installed here): elan + Lean 4.35, pinned in lean-toolchain
lake build                       # builds every project; 'sorry' warnings are expected
lake build Tests.P01Kata         # acceptance tests for one project: red until you're done
lake exe wordfreq --top 5 README.md   # executables, once their project is implemented
```

Open the folder in **VS Code** with the `lean4` extension. The *infoview* panel (goal and type
at the cursor) is your main tool, so keep it open.

### The loop, per project
1. Open `Projects/PNN….lean`. The header comment is the full brief: why, what you'll learn,
   tasks, hints, and stretch goals.
2. Replace the `sorry`s, checking as you go with `#eval` / `#check` and the infoview.
3. Run `lake build Tests.PNN…` until it's green. For proof projects, the tests also check that
   nothing still depends on `sorry`, and list whatever does.
4. For tool projects, finish `main` and run it with `lake exe …`.

> **Note.** A `lake exe` program aborts with `INTERNAL PANIC: executed 'sorry'` while its
> library still has a `sorry` in a top-level *constant*, e.g. `def units : Array … := sorry`.
> Lean evaluates such constants when the program *starts*, before `main` runs. Finish the library first.

Optional but recommended: `git init` and commit after each project.

---

## The roadmap

| # | Project | ≈h | New Lean ideas | You end up with |
|---|---|---|---|---|
| **01** | Kata | 1 | `def`/`match`/`where`, `·`, `\|>`, implicits, `#eval`/`#guard`, `termination_by`, `partial` | 13 classic small functions |
| **02** | `wordfreq` | 3 | `IO`, `do` (`←`, `let mut`, `for`, `try`), `Std.HashMap`, structures, `Except` | a CLI word counter |
| **03** | `huff` | 4 | `inductive` + `deriving`, `ByteArray`, bit ops, binary I/O, edge cases | a working file compressor |
| **04** | Typeclass algebra | 4 | `class`/`instance`/`extends`, `OfNat`/`HMul`, **`Fin n`/`Vector` dims in types**, `#check_failure` | generic `npow`; `fib 10000` instantly; polynomials |
| **05** | Ray tracer | 5 | `Float`, structure update, `infixl` (first macro), `Id.run do` loops, `StateM` RNG | a rendered image |
| **06** | `jsonq` | 5 | **your own `Monad` + `Alternative`**, parser combinators, `partial` + `Inhabited` | a JSON parser/pretty-printer/query tool |
| **07** | Macros | 4 | **`notation`, `syntax`, `macro_rules`, syntax categories, hygiene, command macros** | `json%` literals, list comprehensions, `enum` |
| **08** | `while` REPL | 6 | `ReaderT`/`StateT`/`ExceptT` stacks, monad-polymorphic code, `MonadLift` | an interpreter and REPL |
| **09** | Dependent types | 5 | **indexed families, `Σ`, `▸`, type-level computation**, reducibility | typed evaluator, `Vec`, type-safe `printf` |
| **10** | `sudoku` | 5 | FBIP / in-place `Array`, `dbgTraceIfShared`, bitsets, `Task` parallelism | a fast parallel solver |
| **11** | First proofs | 3 | `theorem`, `simp`/`rw`/`induction`/`cases`/`omega`/`exact?`, `#print axioms` | proofs about *your* P01 code |
| **12** | Verified compiler | 3 | `induction … generalizing`, `@[simp]` lemmas, composing theorems | expr → stack machine, proved correct |
| **13** | Verified sorting | 5 | inductive predicates, `List.Perm`, WF recursion, **`fun_induction`**, `grind`, **`@[csimp]`** | proved isort/msort; isort *runs as* msort |
| **14** | Certified Sudoku | 4 | `Decidable`, `decide` / `+kernel` / `native_decide`, subtypes, Bool↔Prop | P10's solver returns *proofs* |
| **15** | Search tree | 5 | invariants, `ForallKeys`/`BST`, bundled structures, abstraction functions | a verified `TreeMap` |
| **16** | Spec vs. impl. | 4 | **`Std.Do` + `mvcgen` loop invariants**, bounds proofs, `@[csimp]` | verified `for`-loops and binary search |
| **17** | Type safety | 6 | indexed-family proofs, progress/preservation, `HEq` & casts | P09's language proved safe, two ways |
| **18** | Tactics | 4 | **tactic `macro`s, extensible `macro_rules`, `elab`, `TacticM`/`MetaM`** | 7 home-made tactics |
| **19** | Reflection | 6 | verified normalizer + reification in `MetaM`, `ToExpr`, `mkAppM` | `monoid_rfl` / `comm_monoid_rfl` |
| **20** | `vgrep` (capstone) | 8 | everything: inversion lemmas, `decidable_of_iff`, parser reuse, CLI | a regex grep with a *proved* engine |

**Total ≈ 90 hours.** Each project fits in an evening or a weekend.

### Threads through the curriculum

```
Macros         P05 infixl ─→ P07 syntax/macro_rules/categories ─→ P18 tactic macros & elab ─→ P19 MetaM reification
Dependent types P04 Fin/Vector dims ─→ P09 indexed families, Σ, printf ─→ P10 Vector Board ─→ P14 subtypes ─→ P17 HEq/casts
Proofs         P01 termination_by ─→ P11 basics ─→ P12 generalizing ─→ P13 fun_induction/csimp ─→ P14 decide
               ─→ P15 invariants ─→ P16 mvcgen ─→ P17 metatheory ─→ P18–19 automation ─→ P20 everything

Code reuse     P01 ──────────────→ P11 (proofs about your kata)
               P04 Monoid ───────→ P19 (reflective tactic)          P04 fib ───→ P16 (csimp idea)
               P06 Parser ───────→ P08 (While parser), P20 (regex parser)
               P06 JSON ─────────→ P07 (json% literals)
               P09 Expr/UExpr ───→ P17 (type safety, check_sound)
               P10 solver ───────→ P14 (certified)                  P13 isort ──→ P19 (comm. normalizer)
```

---

## Phrasebook

**OCaml/Scala → Lean**

| You know | Lean 4 |
|---|---|
| `let rec f x = …` | `def f (x : τ) : σ := …`. Recursion needs no keyword, but it must terminate (or be `partial`) |
| `fun x -> e` / `x => e` | `fun x => e`, or `(· + 1)` |
| `module M = struct … end` | `namespace M … end M`. Dot notation: `xs.map f` looks up `List.map` |
| functors / Scala implicits | `class` + `instance` + `[C α]` arguments |
| `x \|> f` | `x \|> f`, also `f <\| x` and `xs \|>.map f` |
| `Printf.sprintf "%d" n` | `s!"{n}"` |
| `ref`, `for` loops | `let mut` + `for` inside `do` (pure state threading, even in `Id.run do`) |
| `Option.bind`, `let*` | `do` with `←` works for *any* monad, including yours (P06) |
| exceptions | `Except ε α`, `throw`/`try … catch` in `do`, or `IO` errors |

**Rocq → Lean**

| Rocq | Lean 4 |
|---|---|
| `Fixpoint`, `Function`/`Program Fixpoint` | `def` (structural), `def … termination_by m decreasing_by …` |
| `Inductive`, `Record`, `Class`/`Instance` | `inductive`, `structure`, `class`/`instance` |
| `Theorem … Proof. … Qed.` | `theorem t : P := by …` |
| `intros`, `destruct`, `inversion` | `intro`, `cases`/`rcases`/`obtain`, `cases h` |
| `induction l as [\|x l IH]` | `induction l with \| nil => … \| cons x l ih => …` (+ `generalizing`) |
| `functional induction` | `fun_induction f x` |
| `split` (∧) | `constructor`. **Lean's `split` case-splits an `if`/`match`!** |
| `lia` / `ring` | `omega` / (Mathlib's `ring`; core `grind` handles a lot) |
| `auto`, `easy`, `firstorder` | `simp_all`, `grind`, `trivial`, `decide` |
| `vm_compute; reflexivity` | `decide`, `decide +kernel`, `native_decide` |
| `Search`, `Print Assumptions` | `exact?`/`apply?`/`rw?`, `#print axioms` |
| `Ltac` | `macro` / `macro_rules` / `elab` (P18) |

---

## Lean 4.35 gotchas found while building this

These all came up while checking the projects. The relevant briefs repeat them where they bite.

* **Strings changed recently.** `String.drop`, `trimAscii`, `split` return `String.Slice` (call
  `.toString`). `String.trim` and `String.mk` are gone or deprecated; use `String.ofList`.
  When in doubt, work on `s.toList`.
* **`mvcgen` is deprecated in favor of the experimental `vcgen`**, but `vcgen` didn't handle the
  P16 goals in testing. Use `mvcgen` and `set_option linter.deprecated.syntax false`.
* **Well-founded recursion blocks `decide`.** Such definitions are irreducible. Build things you
  want to `decide` from structural pieces, or use `decide +kernel`.
* **Instance search doesn't unfold plain `def`s.** That's why P09's `printf` results need
  `show String from …`, and why `Ty.denote` is an `abbrev`.
* **Section `variable`s are fixed in recursive calls.** Bind indices that vary, like `n` in
  `Vec α n`, in the `def`'s own signature.
* **Your own capability classes don't auto-lift** through monad transformers (P08). Write
  `(emit s : m Unit)` or a `MonadLift`-based instance.
* **`Except` has no `BEq`.** The tests compare with `.toOption`.
* **Closures aren't tables.** A matrix stored as `Fin m → Fin n → α` recomputes entries
  exponentially under repeated squaring (P04).

---

## How this curriculum was checked

* Every starter file compiles (`lake build`), and every executable links.
* For **every** project, a private reference solution, deliberately *not* included, passes the
  acceptance tests in `Tests/`.
* **Every theorem statement in P11–P20 has been proved** in Lean 4.35 with core tactics only,
  against those reference implementations. None of them is false or needs Mathlib. Statements
  about *your* code (P11, P14, P17) hold for any correct implementation. How hard they are
  depends on how you wrote it, and that's part of the lesson.
* Test helpers live in `Tests/Util.lean` (`#assert_no_sorry`, `#assert_module_sorry_free`, `#assert_csimp`).

## Layout

```
Projects/PNN….lean   your work: the brief (header comment) + skeleton with sorry
Tests/PNN….lean      acceptance tests: lake build Tests.PNN…
Apps/*.lean          two-line `main` wrappers for lake exe
data/                sample inputs: json/, while/, sudoku/ (easy, hard, 200 generated puzzles)
```

## Progress

- [ ] P01 Kata
- [ ] P02 wordfreq
- [ ] P03 huff
- [ ] P04 Typeclasses
- [ ] P05 Ray tracer
- [ ] P06 jsonq
- [ ] P07 Macros
- [ ] P08 while REPL
- [ ] P09 Dependent types
- [ ] P10 sudoku
- [ ] P11 First proofs
- [ ] P12 Verified compiler
- [ ] P13 Verified sorting
- [ ] P14 Certified Sudoku
- [ ] P15 Search tree
- [ ] P16 Spec vs. impl.
- [ ] P17 Type safety
- [ ] P18 Tactics
- [ ] P19 Reflection
- [ ] P20 vgrep

## References

* *Functional Programming in Lean*: https://lean-lang.org/functional_programming_in_lean/ (Part I companion)
* *Theorem Proving in Lean 4*: https://lean-lang.org/theorem_proving_in_lean4/ (Part II companion)
* *The Lean Language Reference*: https://lean-lang.org/doc/reference/latest/ (`do`, `mvcgen`, `grind`, tactics)
* *Metaprogramming in Lean 4*: https://leanprover-community.github.io/lean4-metaprogramming-book/ (P07, P18, P19)
* Loogle, search by type: https://loogle.lean-lang.org/ · Zulip: https://leanprover.zulipchat.com/
* *Ray Tracing in One Weekend*: https://raytracing.github.io/books/RayTracingInOneWeekend.html (P05)
