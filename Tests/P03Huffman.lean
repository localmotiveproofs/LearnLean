import Projects.P03Huffman
/-! Acceptance tests for P03. `lake build Tests.P03Huffman` -/
open P03

def bytes (s : String) : ByteArray := s.toUTF8

/-- total encoded length in bits for a text (helper for tests) -/
def costOf (s : String) : Option Nat := do
  let t ← buildTree (frequencies (bytes s))
  let bits ← encode t (bytes s).toList
  return bits.length

#guard frequencies (bytes "abca") == [(97, 2), (98, 1), (99, 1)]
#guard frequencies ByteArray.empty == []
#guard (buildTree []).isNone
#guard (buildTree [(65, 7)]).map HTree.weight == some 7
#guard (buildTree [(97, 5), (98, 2), (99, 1), (100, 1)]).map HTree.weight == some 9
-- Every Huffman tree for weights 5,2,1,1 has total cost 15 bits, whatever the tie-breaking.
#guard costOf "aaaaabbcd" == some 15
-- Single symbol: still decodable, so it needs a non-empty code.
#guard (do let t ← buildTree (frequencies (bytes "zzz"))
           let bits ← encode t (bytes "zzz").toList
           decode t bits) == some (bytes "zzz").toList
-- Prefix-freeness of the code table.
#guard (do let t ← buildTree (frequencies (bytes "abracadabra"))
           let codes := (codeTable t).map Prod.snd
           return codes.all fun c => codes.all fun d => c == d || !c.isPrefixOf d) == some true
-- Round trips.
#guard (do let s := (bytes "abracadabra").toList
           let t ← buildTree (frequencies (bytes "abracadabra"))
           decode t (← encode t s)) == some (bytes "abracadabra").toList
#guard packBits [true, false, true] == ByteArray.mk #[0b10100000]
#guard unpackBits (ByteArray.mk #[0b10100000, 0xFF]) 10 == [true, false, true, false, false, false, false, false, true, true]
#guard unpackBits (packBits [true, true, false, true, false, false, true, true, true]) 9
         == [true, true, false, true, false, false, true, true, true]
#guard (decompress (compress (bytes "she sells sea shells"))).toOption.map ByteArray.toList
         == some (bytes "she sells sea shells").toList
#guard (decompress (compress ByteArray.empty)).toOption.map ByteArray.toList == some []
#guard (decompress (compress (bytes "aaaa"))).toOption.map ByteArray.toList == some (bytes "aaaa").toList
#guard (decompress (bytes "garbage")).toBool == false
