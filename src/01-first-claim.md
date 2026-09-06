# 1. Turn a requirement into a claim

The scheduler has room for three pending jobs. Two are already queued. Should it accept another? Yes. With three already queued, it must refuse.

Your first task is to turn that boundary into a precise promise and implement it. Work in `exercises/01-first-claim/starter`.

## Read the requirement before the implementation

The admission decision receives `active`, the number of pending jobs, and `capacity`, the queue limit. It should return `true` exactly when `active < capacity`.

“Exactly when” matters. The promise must rule out both admitting too many jobs and refusing a job that fits. A promise that merely says “never exceed capacity” could allow an implementation that rejects everything.

The contract expresses that equivalence:

```rust,ignore
#[ply::ensures(|result| *result == (active < capacity))]
```

`ensures` describes what must be true when the function returns. The closure receives a reference to the result, so `*result` reads the boolean it returned. The parameter names refer to this call's inputs.

Open `src/lib.rs`. Find this promise above `can_claim`. Then open `ply.yaml` and find the function under its component. Its `checks` entry requests generated-input checks with `fuzz`.

In this package, the declaration is:

```yaml
ply: 1
components:
  scheduler:
    anchor: first_claim_starter
    fns:
      can_claim:
        checks: [fuzz(64)]
```

`scheduler` is the component name in the drawing. `first_claim_starter` is the Rust library name to resolve; Cargo changes the package name's hyphens to underscores. Under `fns`, `can_claim` identifies the function whose promise you want checked. `fuzz(64)` requests 64 accepted generated cases.

The annotation states the obligation. The YAML asks Ply to gather evidence for it. Neither replaces the implementation.

## Predict

Write the required answer for each pair before running anything:

| Pending jobs | Capacity | Admit? |
| --- | --- | --- |
| 0 | 1 | |
| 2 | 3 | |
| 3 | 3 | |
| 4 | 3 | |
| 0 | 0 | |

The scheduler rejects a zero-capacity configuration at its boundary. The decision still has a defined result for `(0, 0)`: no room. An exact contract can cover more inputs than the application ordinarily supplies.

Read the starter body and predict which rows it gets wrong.

## Run and repair

```sh
cargo ply check .
cargo ply verify .
```

A valid declaration can still describe broken code. `check` should accept the declaration; `verify` should report a broken promise. Read the failing input and calculate the required answer yourself. Your run may choose a different counterexample from someone else's.

Implement `can_claim` with the admission rule. Keep the contract and requested checks unchanged, then run:

```sh
cargo test
cargo ply verify .
cargo run
```

The last command runs the scheduler demo with your decision. Follow which jobs enter the queue. The tests also exercise the shared scheduler; a correct answer from this one function is only part of a working queue.

<details>
<summary>Hint</summary>

The comparison already returns a boolean. You need neither an `if` statement nor a special case for an empty queue.

</details>

You can also inspect the declared structure without running checks:

```sh
cargo ply render . --text
```

Read the component, function, promise, and requested check in the output. This view describes the declaration; it is not another verification run.

## Explain the evidence

A `fuzz(n)` result means the check exercised generated inputs that satisfied any preconditions and found no broken postcondition among those accepted cases. It does not mean every possible pair of `u32` values was examined.

For this tiny function, you can also inspect the comparison and explain why it matches the requirement. Keep that reasoning separate from what the tool ran.

## Check your learning

1. Someone changes `<` to `<=`. Which row above exposes the defect?
2. `cargo ply check .` exits successfully. Has Ply established that admission behaves correctly?
3. Would “the result is a boolean” be a useful promise for this function? Explain what incorrect behavior it would exclude.
4. A passing admission check is offered as evidence that the queue never loses a job. What is missing?

<details>
<summary>Answers and completion criteria</summary>

1. `(3, 3)` must be refused. `<=` admits it. `(0, 0)` exposes the same boundary error.
2. No. That command runs no verification engines.
3. No. Rust's type already says that, and both “always accept” and “always reject” still return booleans.
4. Queue updates, removal, retry handling, and their callers need separate evidence. The admission predicate alone cannot establish that end-to-end property.

You are ready to continue when the ordinary tests and verification pass, the demo runs, and you can explain why the boundary is strict.

</details>
