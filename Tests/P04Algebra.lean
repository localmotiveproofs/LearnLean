import Projects.P04Algebra
/-! Acceptance tests for P04. `lake build Tests.P04Algebra` -/
open P04

#guard npow (2 : Nat) 10 == 1024
#guard npow (7 : Nat) 0 == 1
#guard npow "ab" 3 == "ababab"
#guard npow "" 1000000 == ""

def A23 : Matrix 2 3 Nat := .ofFn fun i j => i.val * 3 + j.val   -- [[0,1,2],[3,4,5]]
def B32 : Matrix 3 2 Nat := .ofFn fun i j => if i.val == j.val then 1 else 0
#guard (A23 * B32).get 1 1 == 4
#guard (A23 * B32).get 0 1 == 1
#guard ((Matrix.identity 3 : Matrix 3 3 Nat) * (B32 * A23)).get 2 2 == 0
-- dimensions are checked by the type checker:
#check_failure (A23 * A23)

#guard fibFast 0 == 0
#guard fibFast 1 == 1
#guard fibFast 10 == 55
#guard fibFast 90 == 2880067194370816120
#guard (toString (fibFast 10000)).length == 2090

open Poly in
#guard ((X + 1 : Poly Nat) * (X + 1)).coeffs == [1, 2, 1]
#guard (npow (Poly.X + 1 : Poly Nat) 5).coeffs == [1, 5, 10, 10, 5, 1]
#guard (Poly.mk [1, 0, 0] : Poly Nat).normalize == ⟨[1]⟩
#guard ((Poly.X : Poly Int) * Poly.X + Poly.const (-1) * Poly.X * Poly.X).coeffs == []
#guard (Poly.X * Poly.X + 3 : Poly Int).eval 2 == 7
#guard (npow (Poly.X + 1 : Poly Int) 10).eval 1 == 1024
#guard toString (npow (Poly.X + 1 : Poly Nat) 2) == "x^2 + 2x + 1"
#guard toString (Poly.X * Poly.X * 3 + Poly.X * 2 + 1 : Poly Nat) == "3x^2 + 2x + 1"
#guard toString (Poly.X * Poly.X + 1 : Poly Nat) == "x^2 + 1"
#guard toString (Poly.X : Poly Nat) == "x"
#guard toString (5 : Poly Nat) == "5"
#guard toString (0 : Poly Nat) == "0"
