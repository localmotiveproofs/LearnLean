import Projects.P12Compiler
import Tests.Util
/-! Acceptance tests for P12. `lake build Tests.P12Compiler` -/
open P12

def env : String → Int := fun x => if x == "x" then 5 else if x == "y" then -2 else 0
def e1 : AExpr := .sub (.mul (.var "x") (.num 3)) (.add (.var "y") (.num 1))   -- x*3 - (y+1) = 16

#guard e1.eval env == 16
#guard Instr.step env .sub [3, 10] == [7]
#guard Instr.step env .add [1] == [1]
#guard exec env [.push 10, .push 3, .sub] [] == [7]
#guard exec env (compile e1) [] == [16]
#guard exec env (compile e1) [42] == [16, 42]
#guard (AExpr.add (.num 0) (.mul (.var "x") (.num 1))).constFold == .var "x"
#guard (AExpr.mul (.add (.num 2) (.num 3)) (.var "y")).constFold == .mul (.num 5) (.var "y")
#guard (AExpr.mul (.var "z") (.sub (.num 4) (.num 4))).constFold == .num 0
#guard (compile (AExpr.add (.num 1) (.num 2)).constFold).length == 1
#guard decompile (compile e1) == some e1
#guard decompile [.add] == none
#guard decompile [.push 1, .push 2] == none

#assert_no_sorry exec_append compile_correct_gen compile_correct constFold_correct
  compile_constFold_correct decompile_compile
#assert_module_sorry_free Projects.P12Compiler
