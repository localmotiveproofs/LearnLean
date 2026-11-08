import Projects.P20Regex
import Tests.Util
/-! Acceptance tests for P20. `lake build Tests.P20Regex` -/
open P20

def fullMatch (pat str : String) : Option Bool := (parseRegex pat).toOption.map (matchD · str.toList)
def contains (pat str : String) : Option Bool := (parseRegex pat).toOption.map (·.containsMatch str)

-- The derivative matcher
#guard matchD (.star (.cat (.chr 'a') (.chr 'b'))) "abab".toList
#guard !matchD (.star (.cat (.chr 'a') (.chr 'b'))) "aba".toList
#guard matchD (.cat .any (.alt .eps (.chr 'x'))) "qx".toList
#guard !matchD .empty []
-- Matches is decidable, via your verified matcher
example : Matches (.star (.cat (.chr 'a') (.chr 'b'))) "abab".toList := by decide
example : ¬ Matches (.star (.cat (.chr 'a') (.chr 'b'))) "aba".toList := by decide

-- Parsing + full matching
#guard fullMatch "a(b|c)*d" "abcbd" == some true
#guard fullMatch "a(b|c)*d" "abxd" == some false
#guard fullMatch "ab|cd" "ab" == some true
#guard fullMatch "ab|cd" "cd" == some true
#guard fullMatch "ab|cd" "abd" == some false
#guard fullMatch "ab*" "abbb" == some true
#guard fullMatch "ab*" "abab" == some false
#guard fullMatch "a+" "aaa" == some true
#guard fullMatch "a+" "" == some false
#guard fullMatch "colou?r" "color" == some true
#guard fullMatch "colou?r" "colour" == some true
#guard fullMatch "a.c" "abc" == some true
#guard fullMatch "a\\.c" "abc" == some false
#guard fullMatch "a\\.c" "a.c" == some true
#guard fullMatch "" "" == some true
#guard fullMatch "a|" "" == some true
#guard fullMatch "(a|b)*abb" "babaabb" == some true
#guard (parseRegex "(ab").toOption.isNone
#guard (parseRegex "ab)").toOption.isNone
#guard (parseRegex "*a").toOption.isNone
#guard (parseRegex "a\\").toOption.isNone

-- Substring search (what `vgrep` uses)
#guard contains "b+" "abbbc" == some true
#guard contains "^" "x" == some false
#guard contains "lean|rocq" "I like rocq" == some true
#guard contains "x(yz)+" "axyzyzb" == some true
#guard contains "x(yz)+" "axyb" == some false

#assert_no_sorry nullable_iff deriv_iff matchD_iff
#assert_module_sorry_free Projects.P20Regex
