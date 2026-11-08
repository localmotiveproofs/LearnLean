import Projects.P14Certified
import Tests.Util
/-! Acceptance tests for P14. `lake build Tests.P14Certified` -/
open P10 P14

def inkala  := "8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4.."
def inkalaS := "812753649943682175675491283154237896369845721287169534521974368438526917796318452"

#guard (solveCertified euler1).map (·.val.toList) == some euler1Sol.toList
#guard ((parseBoard inkala).bind fun p => (solveCertified p).map fun s => s.val.toLine) == some inkalaS
#guard (certify euler1 euler1).isNone
#guard (certify euler1Sol euler1Sol).isSome
#guard agreesB euler1 euler1Sol && !agreesB euler1Sol euler1

#assert_no_sorry euler1_certified euler1_not_solved isValidSolution_iff agreesB_iff
  certify solveCertified
#assert_module_sorry_free Projects.P14Certified
