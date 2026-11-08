import Projects.P10Sudoku
/-! Acceptance tests for P10. `lake build Tests.P10Sudoku` -/
open P10

def euler1  := "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
def euler1S := "483921657967345821251876493548132976729564138136798245372689514814253769695417382"
def inkala  := "8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4.."
def inkalaS := "812753649943682175675491283154237896369845721287169534521974368438526917796318452"

#guard (parseBoard euler1).isSome
#guard (parseBoard "123").isNone
#guard (parseBoard (euler1.push '1')).isNone
#guard (parseBoard ("x" ++ (euler1.drop 1).toString)).isNone
#guard ((parseBoard inkala).map Board.toLine) == some inkala
#guard ((parseBoard "1 2 3\n4 5 6 7 8 9 ......... ......... ......... ......... ......... ......... ......... .........").map (·[4])) == some 5

#guard rowOf 40 == 4 && colOf 40 == 4 && boxOf 40 == 4
#guard rowOf 80 == 8 && colOf 80 == 8 && boxOf 80 == 8
#guard boxOf 27 == 3 && boxOf 8 == 2 && boxOf 30 == 4
#guard units.size == 27 && units.all (·.size == 9)
#guard units[0]! == #[0, 1, 2, 3, 4, 5, 6, 7, 8]
#guard units[10]! == #[1, 10, 19, 28, 37, 46, 55, 64, 73]
#guard units[19]! == #[3, 4, 5, 12, 13, 14, 21, 22, 23]
#guard (List.finRange 81).all fun i => (peers i).size == 20 && !(peers i).contains i
#guard (peers 0).contains 80 == false && (peers 0).contains 72 && (peers 0).contains 20

#guard ((parseBoard euler1S).map isValidSolution) == some true
#guard ((parseBoard euler1).map isValidSolution) == some false
-- swap two cells within the first row: rows still fine, columns broken
#guard ((parseBoard ("834" ++ (euler1S.drop 3).toString)).map isValidSolution) == some false
#guard ((parseBoard (String.ofList (List.replicate 81 '5'))).map isValidSolution) == some false

#guard ((parseBoard euler1).bind solve |>.map Board.toLine) == some euler1S
#guard ((parseBoard inkala).bind solve |>.map Board.toLine) == some inkalaS
-- inconsistent givens: two 1s in the first row
#guard ((parseBoard ("11" ++ String.ofList (List.replicate 79 '.'))).bind solve).isNone
-- an already-solved board solves to itself
#guard ((parseBoard euler1S).bind solve |>.map Board.toLine) == some euler1S
