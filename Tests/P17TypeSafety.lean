import Projects.P17TypeSafety
import Tests.Util
/-! Acceptance tests for P17. `lake build Tests.P17TypeSafety` -/
open P09 P17

#guard (constFold (Expr.add (.nat 2) (.mul (.nat 3) (.nat 4)))).eval == 14
#guard (constFold (Expr.ite (.lt (.nat 1) (.nat 2)) (.nat 10) (.nat 20))).erase == .nat 10
#guard (constFold (Expr.not (.and (.bool true) (.bool false)))).erase == .bool true
example : HasType (.ite (.bool true) (.nat 1) (.nat 2)) .nat := .ite .bool .nat .nat
example : Step (.add (.nat 1) (.nat 2)) (.nat 3) := .add

#assert_no_sorry constFold_correct canonical_nat canonical_bool progress preservation soundness
  hasType_unique erase_hasType check_sound
#assert_module_sorry_free Projects.P17TypeSafety
