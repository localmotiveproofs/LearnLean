import Projects.P19Reflection
import Tests.Util
/-! Acceptance tests for P19. `lake build Tests.P19Reflection` -/
set_option linter.unusedVariables false
open P04 P19

example {α : Type} [LawfulMonoid α] (a b c d : α) : a * (b * 1) * (c * d) = a * ((b * c) * d) := by
  monoid_rfl
example {α : Type} [LawfulMonoid α] (a : α) : 1 * a * 1 = a := by monoid_rfl
example (s t u : String) : s * (t * u) = (s * t) * u := by monoid_rfl
example {α : Type} [LawfulMonoid α] (a b : α) : True := by
  fail_if_success (have : a * b = b * a := by monoid_rfl)
  trivial

example {α : Type} [LawfulCommMonoid α] (a b c : α) : a * (b * c) = c * (a * b) := by comm_monoid_rfl
example (x y z : Nat) : x * y * (z * x) = x * x * (y * z) := by comm_monoid_rfl
example {α : Type} [LawfulCommMonoid α] (a b : α) : True := by
  fail_if_success (have : a * b = a * a := by comm_monoid_rfl)
  trivial

#assert_no_sorry denoteList_append flatten_correct monoid_reflect denoteList_perm comm_reflect
#assert_module_sorry_free Projects.P19Reflection
