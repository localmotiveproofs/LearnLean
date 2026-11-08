/-!
# P03 · `huff` — a Huffman file compressor

**Part I** · ~4 hours · builds on: P02 · reused by: P13 (optional round-trip proof)

## Why
It's a real tool: it shrinks text files by about 40%. Along the way you write inductive types,
structural recursion, bit twiddling and binary file I/O, which covers most of everyday Lean.

## The tool
```
lake exe huff compress   IN OUT    # writes a .huf file
lake exe huff decompress IN OUT
lake exe huff stats      IN        # per-byte frequency + code, and the compression ratio
```
Suggested file format: a 4-byte magic `HUF1`, then the original length (4 bytes, big-endian),
then the **frequency table** (256 × 4 bytes, or sparse if you like), then the packed bits.
Storing frequencies rather than the tree works as long as `buildTree` is *deterministic*. The
decoder then rebuilds exactly the same tree. That's a nice design point to think about.

## You'll learn
`inductive` types with `deriving Repr, BEq, Inhabited` · structural recursion (and noticing
when you *don't* have it) · `Ord`/`compare` for sorting by weight · `ByteArray`,
`IO.FS.readBinFile` / `IO.FS.writeBinFile` · `UInt8`/`UInt32` and bit ops `<<<`, `>>>`, `&&&`,
`|||`, `.toNat`, `.toUInt8` · `Except String` for "corrupt file" errors · edge cases the type
system doesn't catch for you, such as the single-symbol input.

## Tasks
1. `frequencies`, then `buildTree`. Repeatedly merge the two lightest trees. A sorted list
   used as a priority queue is fine. Break ties deterministically, e.g. by weight and then by smallest symbol.
2. `codeTable`, `encode`, `decode`. Bits are `List Bool` for now (`false` = left).
3. `packBits` / `unpackBits`: turn bits into bytes, MSB first, padding the last byte with zeros.
4. `compress` / `decompress` on whole `ByteArray`s (header + payload), then the CLI in `main`.

**Edge cases you must handle:** an empty input, and a single distinct symbol (the tree is a lone
`leaf` whose code would be empty). One fix is to give that symbol the code `[false]`.

## Done when
`lake build Tests.P03Huffman` is green. Also `lake exe huff compress X Y && lake exe huff decompress Y Z && cmp X Z`
succeeds on a few files, including an empty file and a file containing only `aaaa`.

## Hints
* `ByteArray` ↔ `List UInt8`: `.toList`, `ByteArray.mk xs.toArray`. Lean `String` ↔ bytes:
  `s.toUTF8`, `String.fromUTF8?`.
* `decode` recursion is subtle. You walk down the tree and restart at the root after each leaf.
  The cleanest version has a helper that takes the *current subtree* and the bits left.
* A file of a few MB is fine with `List Bool`. If it's slow, see the stretch goal.

## Stretch
* Replace `List Bool` with a bit writer over `ByteArray` and measure the speed-up (`IO.monoMsNow`).
* Canonical Huffman codes (store only the code *lengths* in the header).
* **In P13** you'll know enough to *prove* `decode t (encode t xs) = some xs` when every symbol
  of `xs` occurs in `t`. Come back and do it.
-/

namespace P03

inductive HTree where
  | leaf (sym : UInt8) (weight : Nat)
  | node (left right : HTree) (weight : Nat)
deriving Repr, BEq, Inhabited

def HTree.weight : HTree → Nat := sorry

/-- Byte frequencies, as a list of `(byte, count)` with `count > 0`, sorted by byte. -/
def frequencies (data : ByteArray) : List (UInt8 × Nat) := sorry

/-- Huffman tree for the given frequencies; `none` iff the list is empty. Must be deterministic. -/
def buildTree (freqs : List (UInt8 × Nat)) : Option HTree := sorry

/-- The code of every symbol in the tree. -/
def codeTable (t : HTree) : List (UInt8 × List Bool) := sorry

/-- Encode; `none` if some symbol is missing from the tree. -/
def encode (t : HTree) (syms : List UInt8) : Option (List Bool) := sorry

/-- Decode; `none` if the bits end in the middle of a code. -/
def decode (t : HTree) (bits : List Bool) : Option (List UInt8) := sorry

/-- Pack bits MSB-first into bytes; the last byte is zero-padded. -/
def packBits (bits : List Bool) : ByteArray := sorry

/-- Unpack the first `n` bits. -/
def unpackBits (bytes : ByteArray) (n : Nat) : List Bool := sorry

def compress (data : ByteArray) : ByteArray := sorry

def decompress (data : ByteArray) : Except String ByteArray := sorry

def main (args : List String) : IO UInt32 := do
  IO.eprintln s!"P03: not implemented yet (args = {args})"
  return 1

end P03
