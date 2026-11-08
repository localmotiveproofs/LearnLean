import Projects.P11FirstProofs
import Tests.Util
/-! Acceptance test for P11: everything is proved, nothing depends on `sorry`. -/
open P11

#assert_no_sorry rev_append rev_rev length_rev rev_eq_reverse last?_append_singleton
  kth?_eq_getElem? kth?_isSome_iff isPalindrome_append_rev length_compress_le unrle_rle
  rle_counts_pos length_range mem_range
#assert_module_sorry_free Projects.P01Kata
#assert_module_sorry_free Projects.P11FirstProofs
