import Std.Data.HashMap
import Projects.P06Json
/-!
# P08 · An interpreter and REPL for a small imperative language, with monad transformers

**Part I** · ~6 hours · builds on: **P06** (your `Parser` monad), P07 · reused by: P12
(compiles this language's arithmetic fragment)

## Why
This is the integration project. Your parser combinators parse a real grammar with precedence.
Your interpreter runs in a **transformer stack**. And because the interpreter is *polymorphic in
the base monad*, the same code runs in `IO` for the REPL and purely in `StateM` for the tests.
That's Scala's tagless-final, with nicer syntax.

## The language
```
stmts   ::= stmt (';' stmt)* ';'?            -- the empty program is fine
stmt    ::= ident ':=' aexp | 'print' aexp | 'skip'
          | 'if' bexp 'then' block ('else' block)?
          | 'while' bexp 'do' block
block   ::= '{' stmts '}'
aexp    ::= term (('+' | '-') term)*                       -- left-associative
term    ::= factor (('*' | '/' | '%') factor)*
factor  ::= int | ident | '(' aexp ')' | '-' factor
bexp    ::= bterm ('||' bterm)*
bterm   ::= bfactor ('&&' bfactor)*
bfactor ::= 'true' | 'false' | '!' bfactor | aexp relop aexp | '(' bexp ')'
relop   ::= '<=' | '<' | '>=' | '>' | '==' | '!='
```
Identifiers are `[A-Za-z_][A-Za-z0-9_]*` and can't be keywords (`print skip if then else while
do true false`). Whitespace, including newlines, is allowed between any two tokens.
Values are `Int`. `/` and `%` are Lean's `Int` operations, *except* that dividing by zero is a
runtime error. Reading an unassigned variable is a runtime error. Every executed statement
(including each loop iteration) costs one step, and exceeding `Config.maxSteps` is a runtime error.

## The tool
```
$ lake exe while                 # REPL; state persists between lines
> x := 6 * 7; print x
42
> :vars          (show all variables)    :reset    :load FILE    :quit
$ lake exe while data/while/primes.while
```

## You'll learn
`ReaderT`/`StateT`/`ExceptT` stacks and automatic lifting · `read`, `get`, `modify`, `throw` ·
writing code generic in a monad `m` with a capability class (`[MonadOutput m]`) · `partial
def` with an `Inhabited` monad · a REPL loop in `IO` with an `IO.Ref` or `StateT` · operator
precedence parsing with combinators (left folds) · multi-module Lake projects (`import
Projects.P06Json`) · keyword vs identifier lexing.

## Tasks
1. Parser: `parseProgram`. Write `aexp`/`term`/`factor` as mutually recursive parsers. One
   `partial def` with local helpers is fine. Order alternatives carefully in `bfactor`: try
   `aexp relop aexp` *before* `'(' bexp ')'`, so that `(x + 1) < 3` works.
2. Interpreter: `AExp.eval`, `BExp.eval`, `Stmt.exec` in `Interp m`.
3. `runProgram`: parse, then run in `StateM (Array String)`, rendering errors as strings
   (see its docstring for the exact format).
4. REPL + file runner in `main`.

## Done when
`lake build Tests.P08While` is green, and `lake exe while data/while/primes.while` prints the
primes below 100.

## Hints
* Recover `Parser` from P06. Keywords: parse an identifier, then reject it if it's in the keyword
  list (so `whilex := 1` is a fine assignment).
* `Interp m α` unfolds to `Config → Store × Nat → m (Except RuntimeError (α × (Store × Nat)))`.
  Write `#check (inferInstance : Monad (Interp IO))` to see that the instances compose.
* Inside `Interp m`, a bare `MonadOutput.emit s` *fails*. Instance search looks for
  `MonadOutput (Interp m)`, and nothing provides it. There are two fixes, and it's worth doing both:
  (a) write `(MonadOutput.emit s : m Unit)`, so `do`-notation's automatic `monadLift` lifts it
  through the stack; (b) write a lifting instance `[MonadLift m n] [MonadOutput m] : MonadOutput n`.
  Core's `MonadState`/`MonadExcept` come with exactly such instances, which is why
  `get`/`throw` just work.

## Stretch
* Error messages with source positions for runtime errors, by keeping positions in the AST.
* `for i := a to b do { … }`, procedures, or arrays.
* A `while% { … }` term macro (P07 style) that builds `Stmt` values at compile time.
-/

namespace P08

inductive AOp | add | sub | mul | div | mod deriving Repr, BEq, Inhabited
inductive ROp | lt | le | gt | ge | eq | ne deriving Repr, BEq, Inhabited

inductive AExp where
  | lit (n : Int)
  | var (x : String)
  | neg (a : AExp)
  | bin (op : AOp) (a b : AExp)
deriving Repr, BEq, Inhabited

inductive BExp where
  | lit (b : Bool)
  | not (b : BExp)
  | and (a b : BExp)
  | or  (a b : BExp)
  | cmp (op : ROp) (a b : AExp)
deriving Repr, BEq, Inhabited

inductive Stmt where
  | assign (x : String) (a : AExp)
  | print (a : AExp)
  | skip
  | seq (s t : Stmt)
  | ite (c : BExp) (t e : Stmt)
  | while (c : BExp) (body : Stmt)
deriving Repr, BEq, Inhabited

/-! ## Parsing (use your P06 combinators) -/

def parseProgram (src : String) : Except P06.ParseError Stmt := sorry

/-! ## The interpreter monad -/

abbrev Store := Std.HashMap String Int

structure Config where
  maxSteps : Nat := 100000

inductive RuntimeError where
  | unbound (x : String)
  | divByZero
  | outOfFuel
deriving Repr, BEq, Inhabited

/-- `"unbound variable: x"`, `"division by zero"`, `"out of fuel"`. -/
def RuntimeError.toString : RuntimeError → String := sorry

class MonadOutput (m : Type → Type) where
  emit : String → m Unit

instance : MonadOutput IO := ⟨IO.println⟩
instance : MonadOutput (StateM (Array String)) := ⟨fun s => modify (·.push s)⟩

/-- Reader: configuration. State: the store and the number of steps taken so far. -/
abbrev Interp (m : Type → Type) := ReaderT Config (StateT (Store × Nat) (ExceptT RuntimeError m))

def AExp.eval {m : Type → Type} [Monad m] : AExp → Interp m Int := sorry
def BExp.eval {m : Type → Type} [Monad m] : BExp → Interp m Bool := sorry
def Stmt.exec {m : Type → Type} [Monad m] [MonadOutput m] : Stmt → Interp m Unit := sorry

/-- Parse and run with an empty store, collecting `print` output.
Errors: `"parse error at {pos}: {msg}"` or `"runtime error: {err.toString}"`. -/
def runProgram (src : String) (cfg : Config := {}) : Except String (List String) := sorry

def main (args : List String) : IO UInt32 := do
  IO.eprintln s!"P08: not implemented yet (args = {args})"
  return 1

end P08
