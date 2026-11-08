/-!
# P06 · Parser combinators from scratch → a JSON parser and `jsonq`

**Part I** · ~5 hours · builds on: P02 · reused by: **P07** (the JSON type), **P08** and
**P20** (your `Parser` monad parses their languages)

## Why
Defining your *own* monad and then watching `do`-notation, `<|>`, `for` and `try`-style
backtracking all just work for it is when Lean's typeclass-driven syntax starts to make sense.
Parsing also brings the termination question into the open: `many p` loops forever if `p`
consumes nothing. You'll make an honest decision about `partial`.

## The tool
```
lake exe jsonq FILE [PATH]      # PATH like  .users[0].name   (default: whole document)
```
Pretty-prints the selected sub-document with 2-space indentation, or reports a parse error with
its position, e.g. `error at 17: expected ':'`. Try it on `data/json/sample.json`.

## You'll learn
`def Parser (α) := Cursor → Except ParseError (α × Cursor)` · `instance : Monad Parser`
(and getting `Functor`/`Applicative` for free) · `instance : Alternative Parser` → `<|>`,
`failure`, `optional` · `do` notation for *your* monad · `partial def` and why it needs an
`Inhabited` instance · `mutual … end` (or one recursive `partial def`) · `Char` predicates,
`String.ofList`, `Char.ofNat`, hex escapes · pretty printing with indentation · `Except.toOption`.

## Tasks
1. `instance : Monad Parser`, `instance : Alternative Parser`. Make `p <|> q` *backtracking*:
   if `p` fails, run `q` from the same cursor.
2. Combinators: `peek?`, `anyChar`, `satisfy`, `pchar`, `pstring`, `eof`, `ws`, `token`,
   `many`, `many1`, `sepBy`. Signatures are below. P08 and P20 will rely on them.
3. `jsonValue` (all of JSON: `null`, booleans, numbers with optional fraction and exponent,
   strings with escapes including `\uXXXX`, arrays, objects) and `parse` (whitespace around, then `eof`).
4. `JSON.compact` and `JSON.pretty`, and the path language `parsePath` / `JSON.get?`.
5. `main` for `jsonq`.

## Done when
`lake build Tests.P06Json` is green and `lake exe jsonq data/json/sample.json .languages[1].name`
prints `"Lean"`.

## Hints
* Numbers: `JNum` stores *mantissa* and *decimal exponent* exactly (`3.14` = `⟨314, 2⟩`,
  `1e3` = `⟨1000, 0⟩`, `-2.5e-1` = `⟨-25, 2⟩`), with no `Float` rounding. Print the canonical
  form with `JNum.toString` (no exponent notation, strip trailing fractional zeros). Any
  representation of the right value is fine, *except* that plain integers like `-12` must parse
  to exponent `0`. The tests compare non-integers through `JNum.toString`.
* Error positions are character offsets. If several alternatives fail, any reasonable error is fine.
* `partial def many (p : Parser α) : Parser (List α)` needs `Inhabited (Parser (List α))`.
  Provide `instance : Inhabited (Parser α) := ⟨fun c => .error ⟨c.pos, "inhabited"⟩⟩`.
  Lean can't find it on its own because `Parser` is a `def`, not an `abbrev`.
* JSON strings in output must be re-escaped (`"` → `\"`, `\` → `\\`, newline → `\n`, other
  control chars → `\u00XX`).

## Stretch
* Commit semantics à la Parsec: an alternative that consumed input doesn't backtrack, which gives
  much better error messages. Add a `try` combinator that restores backtracking.
* Make the parser O(1) per character by switching `List Char` to an `Array Char` + index.
* Line:column error positions with a caret under the offending character.
-/

namespace P06

/-- `mantissa / 10 ^ exponent`. -/
structure JNum where
  mantissa : Int
  exponent : Nat := 0
deriving Repr, BEq, DecidableEq, Inhabited

inductive JSON where
  | null
  | bool (b : Bool)
  | num  (n : JNum)
  | str  (s : String)
  | arr  (elems : List JSON)
  | obj  (fields : List (String × JSON))
deriving Repr, BEq, Inhabited

/-- Canonical decimal rendering: `⟨314, 2⟩ ↦ "3.14"`, `⟨-25, 2⟩ ↦ "-0.25"`, `⟨1000, 0⟩ ↦ "1000"`,
`⟨10, 1⟩ ↦ "1"`, `⟨5, 3⟩ ↦ "0.005"`. -/
def JNum.toString (n : JNum) : String := sorry

/-! ## The parser monad -/

structure Cursor where
  rest : List Char   -- remaining input
  pos  : Nat         -- characters consumed so far
deriving Repr, BEq

structure ParseError where
  pos : Nat
  msg : String
deriving Repr, BEq

def Parser (α : Type) : Type := Cursor → Except ParseError (α × Cursor)

instance : Monad Parser := sorry
instance : Alternative Parser := sorry
instance {α : Type} : Inhabited (Parser α) := ⟨fun c => .error ⟨c.pos, "inhabited"⟩⟩

/-- Run a parser on a string (does *not* require consuming all input). -/
def Parser.run {α : Type} (p : Parser α) (s : String) : Except ParseError α := sorry

def fail {α : Type} (msg : String) : Parser α := sorry
def peek? : Parser (Option Char) := sorry
def anyChar : Parser Char := sorry
def satisfy (pred : Char → Bool) (what : String := "character") : Parser Char := sorry
def pchar (c : Char) : Parser Char := sorry
def pstring (s : String) : Parser String := sorry
def eof : Parser Unit := sorry
/-- Skip whitespace (space, tab, newline, carriage return). -/
def ws : Parser Unit := sorry
/-- `p` followed by optional whitespace. -/
def token {α : Type} (p : Parser α) : Parser α := sorry
def many {α : Type} (p : Parser α) : Parser (List α) := sorry
def many1 {α : Type} (p : Parser α) : Parser (List α) := sorry
def sepBy {α β : Type} (p : Parser α) (sep : Parser β) : Parser (List α) := sorry

/-! ## JSON -/

def jsonValue : Parser JSON := sorry

/-- Parse a complete document (leading/trailing whitespace allowed). -/
def parse (s : String) : Except ParseError JSON := sorry

/-- No whitespace at all: `{"a":[1,2.5,null]}`. -/
def JSON.compact : JSON → String := sorry

/-- Two-space indentation. Empty arrays/objects print as `[]`/`{}`. Example:
```
{
  "a": [
    1,
    true
  ],
  "b": {}
}
``` -/
def JSON.pretty (j : JSON) : String := sorry

inductive PathElem where
  | key (k : String)
  | idx (i : Nat)
deriving Repr, BEq

/-- `".a.b[2].c"` ↦ `[key "a", key "b", idx 2, key "c"]`; `""` and `"."` ↦ `[]`. -/
def parsePath (s : String) : Except String (List PathElem) := sorry

def JSON.get? (j : JSON) (path : List PathElem) : Option JSON := sorry

def main (args : List String) : IO UInt32 := do
  IO.eprintln s!"P06: not implemented yet (args = {args})"
  return 1

end P06
