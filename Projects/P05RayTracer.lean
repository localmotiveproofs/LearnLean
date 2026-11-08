/-!
# P05 · A ray tracer that writes a PPM image

**Part I** · ~5 hours · builds on: P04 (operator instances) · reused by: P10 (parallelism)

## Why
It's the most fun you can have with `Float`, structures and nested loops, and the result is a
picture. You'll write numeric code in a pure language that still *reads* imperatively
(`Id.run do` with `let mut`). You'll also meet your second monad, a random-number generator in
`StateM`.

Follow the first ~9 chapters of Peter Shirley's free *Ray Tracing in One Weekend*
(spheres, surface normals, anti-aliasing, diffuse + metal materials, gamma correction).

## The tool
```
lake exe raytrace out.ppm [WIDTH] [SAMPLES]
```
Writes a binary PPM (`P6`). Most image viewers open it, or convert with `convert out.ppm out.png`.

## You'll learn
`structure` with default fields, anonymous constructors `⟨x, y, z⟩`, `{ r with … }` ·
operator instances on your own types (`HMul Float Vec3 Vec3` for scalar × vector) ·
custom infix notation, your first tiny macro: `infixl:70 " ⬝ " => Vec3.dot` · `Float` API
(`Float.sqrt`, `Float.floor`, `Float.toUInt8`, `Float.ofNat`) · `Id.run do` with nested
`for y in [0:h] do` loops and `let mut` · a `StateM UInt64` random generator (`get`, `set`,
`modifyGet`) · building a `ByteArray` and `IO.FS.writeBinFile` · `IO.monoMsNow` for timing ·
compiled vs interpreted speed (`#eval` vs `lake exe`).

## Tasks
1. `Vec3` with `+`, `-`, unary `-`, scalar `*`, `dot`, `cross`, `length`, `normalize`.
2. `Ray.at`, `hitSphere` (closest hit in `[tMin, tMax]`, with front-face normal).
3. `Rand := StateM UInt64` with xorshift64*: `randFloat ∈ [0,1)`, `randInUnitSphere`.
4. Materials as a closed `inductive` (`lambertian`, `metal`); `scatter` and the recursive
   `rayColor` with a depth limit (structural recursion on `depth`).
5. A camera, anti-aliasing with N samples per pixel, gamma 2, and writing PPM.

## Done when
`lake build Tests.P05RayTracer` is green, and `lake exe raytrace out.ppm 400 50` renders three
spheres on a large "ground" sphere (diffuse + two metals) in under ~30 s.

## Hints
* Prefer `structure Vec3 where x : Float; y : Float; z : Float` plus instances, over a
  `Float × Float × Float` triple: dot-notation and `deriving Repr` come for free.
* Thread the RNG through `rayColor` by making it monadic: `rayColor : Ray → Nat → Rand Vec3`.
  The `for` loops then live in `Rand` instead of `Id`, and only one line changes.
* Hit tests are `Option HitRecord`. Folding over a `List Sphere` to find the nearest is a
  one-liner with `List.foldl`.
* Compiled code is roughly 100× faster than `#eval`. Develop at 100×56 px, render big with `lake exe`.

## Stretch
* Dielectrics (glass), a movable camera, defocus blur.
* Parallel rendering: one `Task.spawn` per band of rows (you'll do more of this in P10).
-/

namespace P05

structure Vec3 where
  x : Float
  y : Float
  z : Float
deriving Repr, BEq, Inhabited

instance : Add Vec3 := sorry
instance : Sub Vec3 := sorry
instance : Neg Vec3 := sorry
/-- scalar * vector -/
instance : HMul Float Vec3 Vec3 := sorry
/-- component-wise product (used for attenuation/colours) -/
instance : Mul Vec3 := sorry

def Vec3.dot (a b : Vec3) : Float := sorry
def Vec3.cross (a b : Vec3) : Vec3 := sorry
def Vec3.length (a : Vec3) : Float := sorry
def Vec3.normalize (a : Vec3) : Vec3 := sorry

-- A first taste of the macro system: a custom infix operator.
infixl:70 " ⬝ " => Vec3.dot

structure Ray where
  origin : Vec3
  dir    : Vec3

def Ray.at (r : Ray) (t : Float) : Vec3 := sorry

structure HitRecord where
  t         : Float
  point     : Vec3
  normal    : Vec3   -- unit length, facing *against* the ray
  frontFace : Bool

structure Sphere where
  center : Vec3
  radius : Float

/-- Closest intersection with `t ∈ [tMin, tMax]`, if any. -/
def hitSphere (s : Sphere) (r : Ray) (tMin tMax : Float) : Option HitRecord := sorry

/-! ## Randomness as a state monad -/

abbrev Rand := StateM UInt64

/-- xorshift64* step; returns a float in `[0, 1)`. -/
def randFloat : Rand Float := sorry

def randInUnitSphere : Rand Vec3 := sorry

/-! ## Rendering — design the rest yourself (materials, world, camera, `render`). -/

/-- Encode a `width × height` image (row-major, top row first) as a binary PPM: the header
`"P6\n{width} {height}\n255\n"` followed by 3 bytes per pixel. Each component `c` is clamped to
`[0, 1]` and stored as `(255.999 * c).toUInt8`. Apply gamma correction *before* calling this. -/
def encodePPM (width height : Nat) (pixels : Array Vec3) : ByteArray := sorry

def main (args : List String) : IO UInt32 := do
  IO.eprintln s!"P05: not implemented yet (args = {args})"
  return 1

end P05
