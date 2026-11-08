/-!
# P09 · Dependent types, gently: a well-typed evaluator, length-indexed vectors, type-safe `printf`

**Part I** · ~5 hours · builds on: P04 (`Fin`), P06 · reused by: **P17** (you'll prove type
safety for exactly this language)

## Why
You know dependent types from Rocq. What's new here is *programming* with them in Lean, where
it's comfortable: dependent pattern matching mostly just works, `Σ` types come with nice
syntax, and the compiler erases the indices. The three classic demos each teach something:
1. **Intrinsically typed expressions.** `Expr : Ty → Type`, so `eval : Expr t → t.denote` *cannot
   fail*. There's no `Value` type and no runtime type errors.
2. **Length-indexed vectors.** `head` needs no `Option`. You'll also hit the famous
   `n + 1 + m` vs `n + m + 1` wall and learn the two ways around it.
3. **Type-level computation.** The *type* of `printf "%d is %s"` is computed from the string:
   `Int → String → String`.

## You'll learn
indexed families (`inductive Expr : Ty → Type`) · type-valued functions (`Ty.denote`) and
why `abbrev` (reducible) matters · dependent pattern matching · `Σ t, Expr t` / `(t : Ty) × Expr t`
· `if h : a = b then … else …` and transport with `h ▸ e` · instances *by cases on a value*
(`instance : (t : Ty) → DecidableEq t.denote`) · `Fin n` · `#check_failure` · `cast` and
`Nat.succ_add` · `show T from e` to force a type that instance search can't see through.

## Tasks
1. `Expr.eval`, `Expr.erase`, `check` (untyped → typed, or `none`), `evalU`.
2. `Vec`: `head`, `tail`, `get`, `map`, `zipWith`, `replicate`, `toList`, `ofList`, `append`,
   `transpose`.
3. `printf` with `%d` (`Int`), `%s` (`String`), `%b` (`Bool`) and `%%` (a literal `%`).

## Done when
`lake build Tests.P09Typed` is green.

## Hints
* `Ty.denote` is an `abbrev` on purpose. Change it to `def` and see what breaks.
* `check (.add a b)`: check both sides, then *pattern match on the type component*:
  `match check a, check b with | some ⟨.nat, a'⟩, some ⟨.nat, b'⟩ => … | _, _ => none`.
* For `ite`/`eq` you need the branch types equal: `if h : t₁ = t₂ then some ⟨t₁, .ite c a (h ▸ b)⟩`.
  `Ty` derives `DecidableEq`, so this is decidable.
* `Vec.append` with result `Vec α (n + m)`, recursing on the first vector: Lean needs
  `n + 1 + m = n + m + 1`. That isn't definitional, because `Nat.add` recurses on its *second*
  argument. Either transport along `Nat.succ_add`, or rephrase. Both are worth doing once.
* Gotcha: an index that *changes* in recursive calls, like `n` in `Vec α n`, must be bound in
  the `def`'s own signature (as below), not by a section-level `variable {n : Nat}`. Section
  variables are fixed for the whole body, so the recursive call can't instantiate them differently.
* `printf`'s result type is `(parseFmt fmt.toList).type`. Instance search won't unfold it to
  `String`, so in tests the result is wrapped in `show String from …`. Ask yourself why.

## Stretch
* Add variables: `Expr (Γ : List Ty) : Ty → Type` with typed de Bruijn indices
  `Mem : Ty → List Ty → Type` and an environment `Env Γ` (a heterogeneous list). Then `let`.
* Add lambdas and application: a tagless STLC interpreter, `eval : Expr Γ t → Env Γ → t.denote`.
* `Vec.reverse`.
-/

namespace P09

inductive Ty where
  | nat
  | bool
deriving DecidableEq, Repr

abbrev Ty.denote : Ty → Type
  | .nat  => Nat
  | .bool => Bool

/-- Intrinsically typed expressions: ill-typed terms are not representable. -/
inductive Expr : Ty → Type where
  | nat  (n : Nat) : Expr .nat
  | bool (b : Bool) : Expr .bool
  | add  (a b : Expr .nat) : Expr .nat
  | mul  (a b : Expr .nat) : Expr .nat
  | lt   (a b : Expr .nat) : Expr .bool
  | eq   {t : Ty} (a b : Expr t) : Expr .bool
  | and  (a b : Expr .bool) : Expr .bool
  | not  (a : Expr .bool) : Expr .bool
  | ite  {t : Ty} (c : Expr .bool) (th el : Expr t) : Expr t

/-- The same language without types: what a parser would produce. -/
inductive UExpr where
  | nat  (n : Nat)
  | bool (b : Bool)
  | add  (a b : UExpr)
  | mul  (a b : UExpr)
  | lt   (a b : UExpr)
  | eq   (a b : UExpr)
  | and  (a b : UExpr)
  | not  (a : UExpr)
  | ite  (c th el : UExpr)
deriving Repr, BEq, DecidableEq

instance decEqDenote : (t : Ty) → DecidableEq t.denote := sorry
instance toStringDenote : (t : Ty) → ToString t.denote := sorry

def Expr.eval {t : Ty} : Expr t → t.denote := sorry

def Expr.erase {t : Ty} : Expr t → UExpr := sorry

/-- Type-check: `some ⟨t, e⟩` with `e.erase = u` if `u` is well-typed, else `none`. -/
def check : UExpr → Option ((t : Ty) × Expr t) := sorry

/-- Check, evaluate, and render the value: `evalU (.add (.nat 1) (.nat 2)) = some "3"`. -/
def evalU (u : UExpr) : Option String := sorry

/-! ## Length-indexed vectors (named `Vec`: core already has an array-backed `Vector`) -/

inductive Vec (α : Type) : Nat → Type where
  | nil  : Vec α 0
  | cons {n : Nat} (head : α) (tail : Vec α n) : Vec α (n + 1)

namespace Vec
variable {α β γ : Type}

def head {n : Nat} : Vec α (n + 1) → α := sorry
def tail {n : Nat} : Vec α (n + 1) → Vec α n := sorry
def get {n : Nat} : Vec α n → Fin n → α := sorry
def map {n : Nat} (f : α → β) : Vec α n → Vec β n := sorry
def zipWith {n : Nat} (f : α → β → γ) : Vec α n → Vec β n → Vec γ n := sorry
def replicate (n : Nat) (a : α) : Vec α n := sorry
def toList {n : Nat} : Vec α n → List α := sorry
def ofList : (l : List α) → Vec α l.length := sorry
def append {n m : Nat} : Vec α n → Vec α m → Vec α (n + m) := sorry
/-- Rows become columns: an `m × n` matrix becomes `n × m`. -/
def transpose {n m : Nat} : Vec (Vec α n) m → Vec (Vec α m) n := sorry
end Vec

/-! ## Type-safe printf — the design is up to you; only `printf` itself is tested. -/

inductive Fmt where
  | int
  | str
  | bool
  | lit (c : Char)
deriving Repr

def parseFmt : List Char → List Fmt := sorry

/-- The type of `printf` for a given format: e.g. `[.int, .lit ' ', .str]` ↦ `Int → String → String`. -/
def Fmt.type : List Fmt → Type := sorry

def printf (fmt : String) : Fmt.type (parseFmt fmt.toList) := sorry

end P09
