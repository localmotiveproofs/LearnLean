import Projects.P09Typed
/-! Acceptance tests for P09. `lake build Tests.P09Typed` -/
open P09

-- Typed evaluation: no Option, no runtime type errors.
#guard (Expr.add (.nat 2) (.mul (.nat 3) (.nat 4))).eval == 14
#guard (Expr.ite (.lt (.nat 1) (.nat 2)) (.nat 10) (.nat 20)).eval == 10
#guard (Expr.eq (.bool true) (.not (.bool false))).eval == true
#guard (Expr.eq (.nat 3) (.add (.nat 1) (.nat 1))).eval == false
#guard (Expr.and (.bool true) (.ite (.bool false) (.bool true) (.bool false))).eval == false
-- Ill-typed terms don't even typecheck:
#check_failure (Expr.add (.nat 1) (.bool true))

-- Erasure and checking
#guard (Expr.ite (.bool true) (.nat 1) (.nat 2)).erase == .ite (.bool true) (.nat 1) (.nat 2)
#guard ((check (.lt (.nat 1) (.nat 2))).map (·.1)) == some .bool
#guard (check (.add (.nat 1) (.bool true))).isNone
#guard (check (.ite (.bool true) (.nat 1) (.bool false))).isNone
#guard (check (.ite (.nat 0) (.nat 1) (.nat 2))).isNone
#guard (check (.eq (.nat 1) (.bool true))).isNone
def samples : List UExpr :=
  [.nat 3, .add (.nat 1) (.mul (.nat 2) (.nat 3)), .eq (.bool true) (.lt (.nat 1) (.nat 0)),
   .ite (.and (.bool true) (.not (.bool false))) (.eq (.nat 1) (.nat 1)) (.bool false)]
#guard samples.all fun u => ((check u).map fun ⟨_, e⟩ => e.erase) == some u
#guard evalU (.add (.nat 1) (.nat 2)) == some "3"
#guard evalU (.ite (.lt (.nat 1) (.nat 2)) (.nat 10) (.nat 20)) == some "10"
#guard evalU (.eq (.nat 3) (.add (.nat 1) (.nat 2))) == some "true"
#guard evalU (.not (.nat 3)) == none

-- Vectors
def v3 : Vec Nat 3 := .cons 10 (.cons 20 (.cons 30 .nil))
#guard v3.head == 10
#guard v3.tail.toList == [20, 30]
#guard v3.get 2 == 30
#guard (v3.map (· + 1)).toList == [11, 21, 31]
#guard (Vec.zipWith (· * ·) v3 v3).toList == [100, 400, 900]
#guard (Vec.replicate 2 'x').toList == ['x', 'x']
#guard (Vec.ofList [1, 2, 3]).toList == [1, 2, 3]
#guard (v3.append (Vec.ofList [4, 5])).toList == [10, 20, 30, 4, 5]
#check_failure (Vec.nil : Vec Nat 0).head
def m23 : Vec (Vec Nat 3) 2 := .cons v3 (.cons (v3.map (· + 1)) .nil)
#guard (m23.transpose.toList.map Vec.toList) == [[10, 11], [20, 21], [30, 31]]
#guard ((Vec.nil : Vec (Vec Nat 2) 0).transpose.toList.map Vec.toList) == [[], []]

-- printf
#guard (show String from printf "%d + %d = %s" 1 2 "three") == "1 + 2 = three"
#guard (show String from printf "%s is %b" "Lean" true) == "Lean is true"
#guard (show String from printf "%d%%" (-5)) == "-5%"
#guard (show String from printf "no args") == "no args"
example : (show String from printf "%d" 42) = "42" := by decide
