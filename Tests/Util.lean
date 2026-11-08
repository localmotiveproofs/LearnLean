import Lean
/-!
Test helpers for the proof projects.

* `#assert_no_sorry thm₁ thm₂ …` fails if any listed declaration depends on `sorry`
  (directly, or through a definition it unfolds).
* `#assert_module_sorry_free Projects.P11FirstProofs` does the same for *every* declaration in a
  module, and lists each one that still uses `sorry`. That makes it a to-do list.
* `#assert_csimp thm` fails unless `thm` is tagged `@[csimp]`.
-/
open Lean Elab Command

private def usesSorry (n : Name) : CommandElabM Bool := do
  let axs ← liftCoreM <| Lean.collectAxioms n
  return axs.contains ``sorryAx

elab "#assert_no_sorry " ids:ident* : command => do
  for id in ids do
    let n ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
    if ← usesSorry n then
      logErrorAt id m!"`{n}` still depends on `sorry`"

elab "#assert_module_sorry_free " mod:ident : command => do
  let env ← getEnv
  let some idx := env.getModuleIdx? mod.getId
    | throwErrorAt mod m!"module `{mod.getId}` is not imported"
  let names := env.header.moduleData[idx.toNat]!.constNames
  let mut bad := #[]
  for n in names do
    if n.isInternal then continue
    if ← usesSorry n then bad := bad.push n
  unless bad.isEmpty do
    logErrorAt mod m!"{bad.size} declaration(s) in `{mod.getId}` still use `sorry`:\n{bad.toList}"

/-- `#assert_csimp thm` fails unless `thm` carries the `@[csimp]` attribute. -/
elab "#assert_csimp " id:ident : command => do
  let n ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
  unless (Lean.Compiler.CSimp.ext.getState (← getEnv)).thmNames.contains n do
    logErrorAt id m!"`{n}` is not tagged `@[csimp]` yet"
