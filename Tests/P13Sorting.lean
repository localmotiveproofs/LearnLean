import Projects.P13Sorting
import Tests.Util
/-! Acceptance tests for P13. `lake build Tests.P13Sorting` -/
open P13

#guard isort [3, 1, 2, 1] == [1, 1, 2, 3]
#guard msort [5, 4, 3, 2, 1, 0, 9] == [0, 1, 2, 3, 4, 5, 9]
#guard msort [] == []
#guard merge [1, 4, 9] [2, 3, 10] == [1, 2, 3, 4, 9, 10]
example : Sorted [1, 2, 2, 7] := .cons (by decide) (.cons (by decide) (.cons (by decide) (.single 7)))

#assert_no_sorry insert_perm insert_sorted isort_perm isort_sorted merge_perm merge_sorted
  msort_perm msort_sorted sorted_perm_eq msort_eq_isort isort_eq_msort
#assert_module_sorry_free Projects.P13Sorting
