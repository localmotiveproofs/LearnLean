import Projects.P02WordFreq
/-! Acceptance tests for P02. `lake build Tests.P02WordFreq` -/
open P02

#guard (parseArgs []).toOption == some {}
#guard (parseArgs ["--top", "3", "a.txt", "--ignore-case", "b.txt"]).toOption
  == some { top := 3, ignoreCase := true, files := ["a.txt", "b.txt"] }
#guard (parseArgs ["--min-length", "4"]).toOption == some { minLength := 4 }
#guard (parseArgs ["--top"]).toBool == false
#guard (parseArgs ["--top", "many"]).toBool == false
#guard (parseArgs ["--frobnicate"]).toBool == false

#guard tokenize {} "Hello, world! Hello." == ["Hello", "world", "Hello"]
#guard tokenize { ignoreCase := true } "Hello, world! Hello." == ["hello", "world", "hello"]
#guard tokenize { minLength := 3 } "a bb ccc dddd" == ["ccc", "dddd"]
#guard tokenize {} "  x1 y_2\n\tz  " == ["x1", "y", "2", "z"]
#guard tokenize {} "" == []

#guard (countWords ["a", "b", "a"]).getD "a" 0 == 2
#guard (countWords ["a", "b", "a"]).getD "c" 0 == 0
#guard (countWords ["a", "b", "a"]).size == 2

#guard topN 2 (countWords ["b", "a", "c", "c", "b", "d"]) == [("b", 2), ("c", 2)]
#guard topN 10 (countWords ["x"]) == [("x", 1)]
#guard topN 0 (countWords ["x"]) == []

#guard formatTable [("the", 41), ("lean", 23)] == "the   41\nlean  23"
#guard formatTable [] == ""
