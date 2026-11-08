import Projects.P08While
/-! Acceptance tests for P08. `lake build Tests.P08While` -/
open P08

def out (src : String) : Option (List String) := (runProgram src).toOption
def err (src : String) : Option String :=
  match runProgram src with
  | .error e => some e
  | .ok _ => none

#guard out "" == some []
#guard out "x := 2; y := x * 3 + 1; print y" == some ["7"]
#guard out "print 1 + 2 * 3; print (1 + 2) * 3; print 10 - 3 - 2; print 7 / 2; print 7 % 3; print -4 + 1"
  == some ["7", "9", "5", "3", "1", "-3"]
#guard out "print 1;" == some ["1"]
#guard out "i := 0; s := 0; while i < 5 do { s := s + i; i := i + 1 }; print s" == some ["10"]
#guard out "x := 5; if x > 3 && !(x == 4) then { print 1 } else { print 0 }; if false || x <= 5 then { print 2 }"
  == some ["1", "2"]
#guard out "if 1 >= 2 then { print 1 } else { print 0 }" == some ["0"]
#guard out "if (1 < 2) && (2 + 1) == 3 then { print 1 }" == some ["1"]
#guard out "if 1 != 1 || true && false then { print 1 } else { skip }" == some []
#guard out "a := 0; b := 1; n := 10;\nwhile n > 0 do {\n  t := a + b; a := b; b := t; n := n - 1\n};\nprint a"
  == some ["55"]
#guard out "whilex := 3; print whilex" == some ["3"]
#guard out "if true then { }" == some []

#guard err "print y" == some "runtime error: unbound variable: y"
#guard err "print 1 / 0" == some "runtime error: division by zero"
#guard err "x := 0; print 5 % x" == some "runtime error: division by zero"
#guard err "while true do { skip }" == some "runtime error: out of fuel"
#guard (runProgram "i := 0; while i < 100 do { i := i + 1 }" { maxSteps := 50 }).toOption == none
#guard ((err "x := ").map (·.startsWith "parse error")) == some true
#guard ((err "while := 3").map (·.startsWith "parse error")) == some true
#guard ((err "print (1 + 2").map (·.startsWith "parse error")) == some true
