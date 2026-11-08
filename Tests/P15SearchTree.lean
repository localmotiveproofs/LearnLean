import Projects.P15SearchTree
import Tests.Util
/-! Acceptance tests for P15. `lake build Tests.P15SearchTree` -/
open P15

def m : TreeMap String := TreeMap.ofList [(5, "five"), (2, "two"), (8, "eight"), (2, "TWO"), (6, "six")]
#guard m.find? 2 == some "TWO"
#guard m.find? 6 == some "six"
#guard m.find? 7 == none
#guard m.toList == [(2, "TWO"), (5, "five"), (6, "six"), (8, "eight")]
#guard (m.insert 7 "seven").toList.map Prod.fst == [2, 5, 6, 7, 8]
#guard (TreeMap.empty : TreeMap Nat).toList == []

#assert_no_sorry Tree.find?_insert_self Tree.find?_insert_ne Tree.forallKeys_insert Tree.insert_BST
  Tree.toList_sorted Tree.find?_eq_some_iff_mem TreeMap.find?_insert TreeMap.find?_empty
  TreeMap.insert TreeMap.ofList
#assert_module_sorry_free Projects.P15SearchTree
