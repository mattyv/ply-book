# Glossary

These definitions describe the course's pinned Ply revision. A declaration can express an intention that this version cannot yet check. Read the scope beside a feature before treating its presence in a diagram as evidence.

Start with [declaration](#declaration), [claim](#claim), [contract](#contract), and [check](#check). For diagrams, see [component](#component), [edge](#edge), [ceiling](#ceiling), and [earned evidence](#earned-evidence). The [visual walkthrough](read-the-evidence.md) puts those terms to work.

## Anchor

The Rust path that connects a component declaration to actual code, for example `anchor: my_crate::queue`. It answers “where is this component implemented?” The component's YAML name answers “what do we call it in the spec?” See [lesson 1](01-first-claim.md).

## Assumption

A condition taken as given by a checking argument. For example, a caller may be checked while relying on a callee's contract. The result establishes only what follows if that assumption holds; it does not silently establish the assumed contract itself.

## Boundary

The limit of a component, system, or verification argument. A boundary contract supplies a promise for code called across that limit. If a check assumes that promise rather than verifying the callee's implementation, the result depends on an [assumption](#assumption). A boundary is not automatically a runtime guard.

## Bounded

`bounded(k)` requests model checking within a stated bound, including limits on loop unwinding. The result applies to the supported model, assumptions, and bound reported by the engine; it is not an unrestricted proof. The number is not a fuzz sample count. This course uses fuzz checks and does not require Kani.

## Capability

A category of effect a component declares it may use: network, filesystem, database, time, randomness, processes, or unsafe operations. YAML spells these `net`, `fs`, `db`, `time`, `rand`, `proc`, and `unsafe` in `uses:`. This is an architectural permission, not an operating-system sandbox. The pinned version does not enforce item-level capability use.

## Ceiling

The strength of the checks requested by a declaration. In a declaration render, grey depth represents this ceiling; the weakest declared function limits the component's ceiling. Darker grey does not mean verification succeeded. Unlisted Rust functions are not automatically included in that summary.

## Check

A requested verification method, such as `test`, `fuzz(64)`, or `bounded(2)`, listed under `checks:`. This is distinct from **`cargo ply check`**, the command that validates declarations and runs available structural checks. **`cargo ply verify`** runs the requested contract checks. See the [setup command table](setup.md#learn-the-commands).

## Claim

An obligation submitted to Ply, such as a function's contract or an architecture rule. A claim says what should hold; evidence records what checking established about it. A passing claim may still be too weak to capture the application's requirement; [lesson 3](03-evidence-limits.md) demonstrates this.

## Component

A named architectural unit declared in `ply.yaml` and connected to Rust code through an [anchor](#anchor). Components can nest. A component is not necessarily a crate or a module, and its drawing does not automatically account for every function in the application.

## Conditional

A qualification saying that a result rests on assumed contracts. Inspect which contracts support it and what evidence exists for their implementations before relying on the combined argument.

## Contract

The conditions attached to a function: its [preconditions](#precondition) and [postconditions](#postcondition). Contracts can be written as Rust attributes or in YAML where supported. They describe behavior; ordinary Rust execution does not automatically enforce Ply's attributes.

## Counterexample

A concrete input exposing a failed claim, sometimes abbreviated `cex` or called a witness. Inspect both the input and the diagnostic: in lesson 4, evaluation panics before the postcondition can run. A compiler error is not a counterexample to the function's behavior.

## Declaration

An entry in the specification describing structure, a rule, or requested checking. For example, listing `retry_delay_ms` under `fns` declares a function claim. Writing a declaration does not run a check.

## Deny rule

An explicit prohibition under `deny:`. For example, `worker -> storage` in that list forbids the relationship that the same string under `edges:` would permit. Patterns can use `*` and an `except` list. An exception removes that denial for the listed component; it does not itself supply a missing permission.

In the pinned version, crate-level denials are checked against Cargo's dependency graph. Item-level call denials are declarations only. A red barred arrow depicts the prohibition; its existence alone does not mean code violated it. See the [architecture reference](https://github.com/mattyv/ply/blob/0ae6f7d37b6a385e7b1283a0d43e0d1c2cb586d9/docs/SCHEMA.md#8-architecture-edges-denials-capabilities-ownership).

## Diagnostic

A message explaining a finding, with a code such as `P0502`, a severity, and relevant details or source locations. A warning can accompany passing evidence. `cargo ply explain P0502` explains the code; the run's own message explains this occurrence.

## Earned evidence

What a completed check actually established for a particular claim and scope. Green function chips indicate earned evidence; read the verdict and qualifications to learn what kind. In the course, `fuzzed(64)` means 64 accepted generated cases passed. It does not mean the whole scheduler is proved correct.

## Edge

A declared directed relationship between components. Under `edges:`, `worker -> storage` permits a call or dependency in that direction; it does not assert that the call happens. Permission in one direction does not imply the reverse or a transitive permission through other components.

A flow edge, `worker ~> storage : Job`, records intended data flow. Flow edges are drawn, not checked. The course's pinned version checks crate-level dependencies against Cargo metadata; it does not enforce item-level calls between modules in the same crate. A drawn arrow alone is never evidence that an engine checked that relationship.

## Engine

The checking tool Ply uses to gather evidence, such as proptest for generated-input checking or Kani for bounded checking. Ply coordinates the tool and reports its outcome. A missing engine means the requested evidence was not earned.

## Entry point

A function declared reachable by an external through `entry:`. Its preconditions become assumptions about the outside caller; drawing this entry does not establish that outside inputs satisfy them. Validate such inputs at the application's runtime boundary.

## External

An actor outside the declared codebase, listed under `externals:`, such as an operator or another service. Ply can draw its relationship to your system but cannot verify the external actor. An external is different from a Rust dependency crate that Ply can inspect.

## Fingerprint

A hash of tracked inputs on which a saved result depends, used to decide whether that result can be reused. It is not proof of program correctness, and its coverage depends on the Ply version. Matching fingerprints cannot detect a change to an input that version does not track.

## Fuzz

`fuzz(n)` requests generated-input checking. For the input-taking functions in this course, a passing `fuzzed(n)` result records `n` accepted cases satisfying the preconditions. Those cases are finite evidence, not an exhaustive proof. A precondition can exclude much of the input domain; read rejection warnings too.

## Harness

A generated Rust program that sets up inputs, calls code, and evaluates a claim through an engine. Harnesses under `target/ply/` are temporary checking machinery. Repair your source or declaration rather than editing them.

## Invariant

A property intended to remain true of state, such as a queue length never exceeding its capacity. Ply's `state.holds` declares such properties. A passing admission predicate alone does not establish a queue invariant: the state transitions also matter. Declaring an invariant is separate from establishing it at the places where the implementation can change state.

## Name

An identifier in a Ply declaration, such as `scheduler` under `components`. Component names use lowercase snake_case. This identifier belongs to the specification; it need not match the Rust path in the component's anchor. Names identify things; [references](#reference) use those names to point to them.

## Owed evidence

Evidence still needed for an assumed contract that has not been checked against its implementation. This makes a verification dependency visible. It is different from an environmental assumption about an external actor, which this codebase cannot discharge by checking its own code.

## Owns

`owns:` names types whose mutation is assigned to a component. This is architectural responsibility, not Rust's ownership or borrowing system. The pinned version draws and validates the declaration but does not enforce the item-level mutation rule.

## Postcondition

A condition that must hold when the function returns, written with `ensures`. In `|result| *result == (active < capacity)`, `result` refers to the returned value. The promise must exclude the wrong behavior you care about, not merely restate the return type.

## Precondition

A condition that must hold on entry for the function's promise to apply, written with `requires`. Generated-input checks accept only inputs satisfying it. It is the caller's obligation, not an automatic runtime guard. See [lesson 2](02-first-failure.md).

## Profile

A named set of restrictions a component adopts, such as bans on particular source constructs. It is not Cargo's development or release build profile. Read the pinned [profile reference](https://github.com/mattyv/ply/blob/0ae6f7d37b6a385e7b1283a0d43e0d1c2cb586d9/docs/SCHEMA.md#profiles) and the command's report to distinguish declared policy from checked findings.

## Pure

`pure: true` declares that a component uses no capabilities. It is an architectural promise; this flag alone is not proof that the implementation has no side effects. Capability enforcement is outside the pinned version's item-level checks.

## Reference

A use of a declared name to identify a component or external, for example an endpoint in an [edge](#edge). `scheduler.queue` identifies a nested component; `my_crate::queue` is a Rust path instead. Prefer the qualified component spelling when a short name could suggest more than one target; Ply reports ambiguous or shadowed names.

Here, “reference” does **not** mean Rust's `&T`. In a postcondition, a reference to the returned value is an ordinary Rust reference. A “reference page” is documentation. Context distinguishes these uses.

## Regression test

A test kept after a repair to catch a return of the same defect. Ply can generate one from a counterexample in `src/ply_generated_cex.rs`. Unlike the checking harness, this file is useful lasting evidence: retain it and run it with `cargo test`.

## Reused result

Previously recorded evidence that Ply carries forward when its tracked inputs still match. Reuse avoids running the same check again, but applies only to what Ply tracks. A newly completed run can contain reused results. See [lesson 3](03-evidence-limits.md) for a contract change that causes rechecking.

## Run

One invocation of checking that produces recorded outcomes and diagnostics. A run can finish with a violation or missing evidence; “completed” does not mean “passed.”

## Shrinking

Reducing a failing input to a simpler counterexample that still exposes the failure. A shrunk result helps explain and reproduce a bug; it need not be the globally smallest failing input. See [lesson 4](05-missed-input.md).

## Snapshot

The saved visual representation of a completed run. `--publish-view` writes local artifacts for a viewer; it does not publish your project to a website. A snapshot records past evidence. Editing source or refreshing the viewer does not verify the edited code.

## Status

A qualification accompanying an outcome, such as evidence being conditional on another promise. Read the named condition and explanation; one reassuring label should not erase a qualification elsewhere in the report.

## Trusted

A human-attested claim with a named supporting artifact, such as a specialised test or an audit. It runs no verification engine and does not upgrade a verdict. The artifact must be inspected on its own merits. In the pinned version, automatic re-attestation after source changes is not implemented.

## Unclaimed

No checking evidence has been established for the item in this context. It can occur when no check was requested. A declaration-only render also presents its items as unclaimed because rendering runs no engines—even if you verified the code separately. It does not mean a check found a bug.

## Unsupported

Ply or the selected engine cannot perform the requested checking for this case, for example because it cannot construct the input shape or has no postcondition to check. Read the specific reason. It is an absence of the requested evidence, not a passing result or a demonstrated behavioral defect.

## Verdict

The recorded outcome for a claim, such as `violation` or `fuzzed(64)`. Read it with the claim, evidence details, and any [statuses](#status) or [diagnostics](#diagnostic). A passing function verdict is not a verdict on every requirement of the application.

## Violation

A check found that an obligation failed. For a function, inspect the failing witness; for architecture, inspect the offending dependency. A tool error or timeout is different: it does not establish that the code broke its promise.
