import Projects.P06Json
/-! Acceptance tests for P06. `lake build Tests.P06Json` -/
open P06

-- JNum rendering
#guard JNum.toString ⟨314, 2⟩ == "3.14"
#guard JNum.toString ⟨-25, 2⟩ == "-0.25"
#guard JNum.toString ⟨1000, 0⟩ == "1000"
#guard JNum.toString ⟨10, 1⟩ == "1"
#guard JNum.toString ⟨5, 3⟩ == "0.005"
#guard JNum.toString ⟨0, 0⟩ == "0"

-- Combinators
#guard ((pstring "ab").run "abc").toOption == some "ab"
#guard ((pstring "ab").run "axc").toOption == none
#guard ((many (pchar 'a')).run "aaab").toOption == some ['a', 'a', 'a']
#guard ((many (pchar 'a')).run "b").toOption == some []
#guard ((many1 (pchar 'a')).run "b").toOption == none
#guard ((sepBy (satisfy Char.isDigit) (pchar ',')).run "1,2,3").toOption == some ['1', '2', '3']
#guard ((pchar 'x' <|> pchar 'y').run "y").toOption == some 'y'
-- backtracking: the first alternative consumes 'a' and then fails; the second starts over
#guard ((pstring "ab" <|> pstring "ac").run "ac").toOption == some "ac"
#guard ((do let a ← anyChar; let b ← anyChar; eof; return [b, a] : Parser _).run "xy").toOption == some ['y', 'x']
#guard ((do let _ ← anyChar; eof : Parser Unit).run "xy").toOption == none
#guard ((token (pchar 'a') *> pchar 'b').run "a  \n b").toOption == some 'b'

-- JSON parsing
#guard (parse "null").toOption == some .null
#guard (parse " [1, -2, true, false] ").toOption == some (.arr [.num ⟨1, 0⟩, .num ⟨-2, 0⟩, .bool true, .bool false])
#guard (parse "{\"a\": {\"b\": []}, \"c\": \"d\"}").toOption
  == some (.obj [("a", .obj [("b", .arr [])]), ("c", .str "d")])
#guard (parse "\"tab\\tquote\\\"slash\\\\u\\u00e9\"").toOption == some (.str "tab\tquote\"slash\\ué")
#guard (parse "[1, 2").toOption == none
#guard (parse "{\"a\" 1}").toOption == none
#guard (parse "[1] x").toOption == none
#guard (parse "").toOption == none

def compactOf (s : String) : Option String := (parse s).toOption.map JSON.compact

#guard compactOf "3.14" == some "3.14"
#guard compactOf "1.50" == some "1.5"
#guard compactOf "1e3" == some "1000"
#guard compactOf "-2.5e-1" == some "-0.25"
#guard compactOf " { \"a\" : [ 1 , 2.5 , null ] } " == some "{\"a\":[1,2.5,null]}"
#guard compactOf "\"line\\nbreak \\\"q\\\"\"" == some "\"line\\nbreak \\\"q\\\"\""

#guard (JSON.obj [("a", .arr [.num ⟨1, 0⟩, .bool true]), ("b", .obj [])]).pretty
  == "{\n  \"a\": [\n    1,\n    true\n  ],\n  \"b\": {}\n}"
#guard (JSON.arr []).pretty == "[]"

-- Paths
#guard (parsePath ".a.b[2].c").toOption == some [.key "a", .key "b", .idx 2, .key "c"]
#guard (parsePath "").toOption == some []
#guard (parsePath ".").toOption == some []
#guard (parsePath "[0][1]").toOption == some [.idx 0, .idx 1]
#guard (parsePath ".a[").toOption == none

#guard (do let j ← (parse "{\"xs\": [10, {\"y\": 7}]}").toOption
           j.get? [.key "xs", .idx 1, .key "y"]) == some (.num ⟨7, 0⟩)
#guard (do let j ← (parse "{\"xs\": [10]}").toOption
           j.get? [.key "xs", .idx 5]) == none
