import Projects.P16SpecImpl
import Tests.Util
/-! Acceptance tests for P16. `lake build Tests.P16SpecImpl` -/
open P16

#guard fibLoop 10 == 55
#guard fibLoop 90 == 2880067194370816120
#guard sumSquares #[1, 2, 3] == 14
#guard maxOf? [3, 9, 2] == some 9
#guard maxOf? [] == none
#guard binSearch #[1, 3, 5, 7, 9, 11] 7 == some 3
#guard binSearch #[1, 3, 5, 7, 9, 11] 4 == none
#guard binSearch #[] 4 == none
#guard (List.range 50).all fun x => (binSearch ((List.range 50).map (· * 2)).toArray (2 * x)).isSome

#assert_no_sorry fibLoop_eq fibSpec_eq_fibLoop sumSquares_eq maxOf?_spec maxOf?_eq_none
  binSearch_sound binSearch_complete
#assert_csimp fibSpec_eq_fibLoop
#assert_module_sorry_free Projects.P16SpecImpl
