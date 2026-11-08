import Projects.P05RayTracer
/-! Acceptance tests for P05. `lake build Tests.P05RayTracer` -/
open P05

def v (x y z : Float) : Vec3 := ⟨x, y, z⟩

#guard v 1 2 3 + v 1 1 1 == v 2 3 4
#guard v 1 2 3 - v 1 1 1 == v 0 1 2
#guard -(v 1 2 3) == v (-1) (-2) (-3)
#guard (2.0 : Float) * v 1 2 3 == v 2 4 6
#guard v 1 2 3 * v 2 2 2 == v 2 4 6
#guard v 1 2 3 ⬝ v 4 5 6 == 32
#guard (v 1 0 0).cross (v 0 1 0) == v 0 0 1
#guard (v 3 4 0).length == 5
#guard (v 0 0 5).normalize == v 0 0 1
#guard ({ origin := v 0 0 0, dir := v 1 2 3 } : Ray).at 2 == v 2 4 6

-- A unit sphere 5 units down the -z axis; a ray from the origin straight at it hits at t = 4.
def s : Sphere := { center := v 0 0 (-5), radius := 1 }
def r : Ray := { origin := v 0 0 0, dir := v 0 0 (-1) }
#guard ((hitSphere s r 0.001 100).map (·.t)) == some 4
#guard ((hitSphere s r 0.001 100).map (·.normal)) == some (v 0 0 1)
#guard ((hitSphere s r 0.001 100).map (·.frontFace)) == some true
#guard (hitSphere s r 0.001 3).isNone
#guard (hitSphere s { r with dir := v 0 1 0 } 0.001 100).isNone
-- From inside the sphere the hit is on the far side, and the normal is flipped against the ray.
#guard ((hitSphere s { r with origin := v 0 0 (-5) } 0.001 100).map (·.frontFace)) == some false

-- The RNG stays in range and changes its state.
#guard (Id.run do
  let mut ok := true
  let mut seed : UInt64 := 42
  for _ in [0:1000] do
    let (x, seed') := randFloat.run seed
    ok := ok && 0 ≤ x && x < 1 && seed' != seed
    seed := seed'
  return ok)

#guard (encodePPM 1 1 #[v 1 0 0]).toList == "P6\n1 1\n255\n".toUTF8.toList ++ [255, 0, 0]
