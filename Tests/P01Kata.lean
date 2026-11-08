import Projects.P01Kata
/-! Acceptance tests for P01. `lake build Tests.P01Kata` -/
open P01

#guard last? [1, 2, 3] == some 3
#guard last? ([] : List Nat) == none
#guard kth? ['a', 'b', 'c'] 1 == some 'b'
#guard kth? ['a', 'b', 'c'] 3 == none
#guard rev [1, 2, 3] == [3, 2, 1]
#guard rev ([] : List Nat) == []
#guard isPalindrome "racecar".toList
#guard !isPalindrome [1, 2]
#guard isPalindrome ([] : List Nat)
#guard compress [1, 1, 2, 1, 1, 3, 3] == [1, 2, 1, 3]
#guard pack [1, 1, 2, 1] == [[1, 1], [2], [1]]
#guard pack ([] : List Nat) == []
#guard rle "aaabccaa".toList == [('a', 3), ('b', 1), ('c', 2), ('a', 2)]
#guard rle ([] : List Nat) == []
#guard unrle [('x', 2), ('y', 1)] == ['x', 'x', 'y']
#guard unrle (rle "mississippi".toList) == "mississippi".toList
#guard range 3 6 == [3, 4, 5, 6]
#guard range 5 5 == [5]
#guard range 6 3 == []
#guard (List.range 30).filter isPrime == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
#guard isPrime 7919
#guard gcd' 48 18 == 6
#guard gcd' 0 5 == 5
#guard gcd' 7 0 == 7
#guard goldbach? 28 == some (5, 23)
#guard goldbach? 4 == some (2, 2)
#guard goldbach? 27 == none
#guard collatzSteps 1 == 0
#guard collatzSteps 6 == 8
#guard collatzSteps 27 == 111
