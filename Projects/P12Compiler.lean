/-!
# P12 · A verified compiler: arithmetic expressions → stack machine

**Part II** · ~3 hours · builds on: P08 (this is its arithmetic fragment), P11 · reused by: P18

## Why
The classic first verified-programming result, as in McCarthy & Painter (1967) or chapter 1 of
CPDT. It's small enough to finish in an evening and real enough to feel like a result. The
proof technique you learn here, **strengthening the induction hypothesis by generalizing over
the rest of the program and the stack**, comes back all the time.

## You'll learn
`induction e generalizing s` (the key move) · proving a *lemma about `++`* first so the main
induction is clean · your own `@[simp]` lemmas and simp-normal forms · `simp [*]` / `simp_all` ·
`decide` and `rfl` on closed examples · the "compile → optimize → compile" pipeline and
**composing** correctness theorems · structural induction on *two* things at once (the decompiler).

## Tasks
1. Define `eval`, `Instr.step`, `exec` and `compile` (postfix order). The semantics of `sub`
   are pinned in `Instr.step`'s docstring.
2. Prove `exec_append`, then `compile_correct_gen`, then `compile_correct`.
3. A constant-folding optimizer with algebraic simplifications, proven correct, and the
   composed theorem `compile_constFold_correct`.
4. A *decompiler* `decompile : List Instr → Option AExpr` with `decompile (compile e) = some e`.
   This needs its own generalization: run a stack of `AExpr`s.

## Done when
No `sorry` in this file, and `lake build Tests.P12Compiler` is green.

## Hints
* State `exec` via `List.foldl` or by direct recursion. Direct recursion gives nicer equation
  lemmas (`exec env (i :: is) s = exec env is (i.step env s)`).
* If `compile_correct_gen` gets stuck, look at what the inductive hypotheses quantify over.
  `generalizing s` is usually the fix.
* For the optimizer, define smart constructors `mkAdd`/`mkMul` (folding `0 + e`, `e * 1`,
  `e * 0`, and constant pairs), prove `(mkAdd a b).eval env = a.eval env + b.eval env`, then
  the main theorem is a one-liner per case. Note `e * 0 = 0` is fine: there are no side effects.
* `Int` arithmetic facts: `omega` handles linear ones, `Int.mul_comm` & co. the rest, or `grind`.

## Stretch
* `let x := e₁ in e₂` with `store`/`load` instructions. The environment changes, so you have
  to generalize over `env` too.
* Prove a stack-depth bound: executing `compile e` never needs more than `depth e` extra slots.
* Booleans and `if` with relative jumps (`jmpIfZero k`). You'll need a program-counter
  machine with fuel. This is substantially harder and very satisfying.
-/

namespace P12

inductive AExpr where
  | num (n : Int)
  | var (x : String)
  | add (a b : AExpr)
  | sub (a b : AExpr)
  | mul (a b : AExpr)
deriving Repr, DecidableEq

def AExpr.eval (env : String → Int) : AExpr → Int := sorry

inductive Instr where
  | push (n : Int)
  | load (x : String)
  | add
  | sub
  | mul
deriving Repr, DecidableEq

/-- The top of the stack is the head of the list. `add`/`sub`/`mul` pop `b` (top) then `a`
and push `a + b` / `a - b` / `a * b`. On stack underflow the stack is left unchanged. -/
def Instr.step (env : String → Int) : Instr → List Int → List Int := sorry

def exec (env : String → Int) : List Instr → List Int → List Int := sorry

def compile : AExpr → List Instr := sorry

theorem exec_append (env : String → Int) (p q : List Instr) (s : List Int) :
    exec env (p ++ q) s = exec env q (exec env p s) := sorry

theorem compile_correct_gen (env : String → Int) (e : AExpr) (s : List Int) :
    exec env (compile e) s = e.eval env :: s := sorry

theorem compile_correct (env : String → Int) (e : AExpr) :
    exec env (compile e) [] = [e.eval env] := sorry

/-! ## Optimization -/

/-- Fold constants and simplify `0 + e`, `e + 0`, `e - 0`, `1 * e`, `e * 1`, `0 * e`, `e * 0`. -/
def AExpr.constFold : AExpr → AExpr := sorry

theorem constFold_correct (env : String → Int) (e : AExpr) :
    e.constFold.eval env = e.eval env := sorry

theorem compile_constFold_correct (env : String → Int) (e : AExpr) :
    exec env (compile e.constFold) [] = [e.eval env] := sorry

/-! ## Decompilation -/

def decompile (is : List Instr) : Option AExpr := sorry

theorem decompile_compile (e : AExpr) : decompile (compile e) = some e := sorry

end P12
