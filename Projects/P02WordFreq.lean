import Std.Data.HashMap
/-!
# P02 · `wordfreq` — your first real executable

**Part I** · ~3 hours · builds on: P01 · reused by: P03 (CLI patterns), P06 (`main` style)

## Why
You learn a language's real shape by shipping a program that reads files, parses flags, uses a
hash map and prints a table. This is the `IO` + `do`-notation project.

## The tool
```
lake exe wordfreq [--top N] [--min-length K] [--ignore-case] [FILE ...]
```
* Reads every FILE, or **stdin** if there are none, and counts words.
* A *word* is a maximal run of alphanumeric characters (`Char.isAlphanum`).
* Shorter words than `--min-length` (default 1) are skipped. With `--ignore-case`, words are lowercased.
* Prints the `--top` (default 10) words: highest count first, ties broken alphabetically.
  Then prints a summary line `total: T, unique: U`.
* Exit codes: `0` ok, `1` bad arguments (print usage to stderr), `2` unreadable file.

```
$ lake exe wordfreq --top 3 --ignore-case README.md
the      41
lean     23
a        19
total: 812, unique: 371
```

## You'll learn
`def main (args : List String) : IO UInt32` · `do` blocks: `let x ← act`, nested actions
`(← act)`, `let mut`, `for … in …`, early `return`, `try … catch`, `unless`/`if … then` ·
`IO.FS.readFile`, `IO.getStdin` + `Stream.getLine` · `IO.println` / `IO.eprintln` ·
`Std.HashMap` (`insert`, `getD`, `alter`, `fold`, `toList`) · sorting (`Array.qsort` with a
custom `lt`) · `structure` with default field values and `{ cfg with top := n }` update syntax ·
`Except` for pure error handling · `deriving Repr, BEq`.

## Tasks
1. `parseArgs`: pure, so it can be tested. Walk the argument list recursively.
2. `tokenize`, `countWords`, `topN`, `formatTable`: pure.
3. `main`: glue in `IO`. Keep it thin. Wire it up in `Apps/WordFreq.lean`.

## Done when
`lake build Tests.P02WordFreq` is green, and `lake exe wordfreq --top 5 Projects/*.lean` prints a
sensible table. Also try `cat Projects/*.lean | lake exe wordfreq`.

## Hints
* Strings changed a lot in recent Lean. Many operations (`drop`, `trimAscii`, `split`) return a
  `String.Slice` view rather than a `String`, and you call `.toString` to get a `String` back. For
  this project it's simplest to work on `s.toList : List Char` and go back with `String.ofList`.
* Reading stdin to the end: get `← IO.getStdin`, then loop `let line ← stdin.getLine` until it
  returns `""`. Lean's `do` has `repeat` + `break`, or write a small recursive `partial def`.
* `for` over a `List`/`Array`/range `[0:n]` works in *any* monad. `let mut` variables are
  sugar for state threading, not real mutation.
* `Array.qsort xs (fun a b => …)` takes a strict "less than".
* The infoview shows the type of every `←`; hover over `do` elements when confused.

## Stretch
* `--json` output flag (you'll have a JSON printer after P06; come back).
* Read files concurrently with `IO.asTask` and merge the maps.
-/

namespace P02

structure Config where
  top        : Nat := 10
  minLength  : Nat := 1
  ignoreCase : Bool := false
  files      : List String := []
deriving Repr, BEq

/-- Parse command-line flags. Unknown flags, missing or non-numeric values → `.error msg`.
Flags may appear anywhere; non-flag arguments are files, in order. -/
def parseArgs (args : List String) : Except String Config :=
  let rec aux args (config: Config) : Except String Config := do
    match args with
    | [] => pure config
    | "--top" :: n_str :: args' => aux args' {config with top := n_str.toNat! }
    | "--min-length" :: k_str :: args' => aux args' {config with minLength := k_str.toNat!}
    | "--ignore-case" :: args' => aux args' {config with ignoreCase := true}
    | file :: args' => aux args' {config with files := file :: config.files}
  aux args {}

/-- Split text into words according to the config (`minLength`, `ignoreCase`). -/
def tokenize (cfg : Config) (text : String) : List String :=
  let rec eat cfg pref suff :=
    match suff with
    | a :: t => if Char.isAlphanum

def countWords (words : List String) : Std.HashMap String Nat := sorry

/-- The `n` most frequent words: count descending, then word ascending. -/
def topN (n : Nat) (counts : Std.HashMap String Nat) : List (String × Nat) := sorry

/-- One line per entry: word left-aligned and padded to the longest word + 2, then the count.
Lines are joined with `"\n"` (no trailing newline). -/
def formatTable (rows : List (String × Nat)) : String := sorry

def main (args : List String) : IO UInt32 := do
  IO.eprintln s!"P02: not implemented yet (args = {args})"
  return 1

end P02
