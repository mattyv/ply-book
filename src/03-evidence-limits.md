# 3. Challenge a passing result

The scheduler now counts attempts correctly. Its next requirement is to wait longer between retries: 100 milliseconds, then 200, then 400.

Work in `exercises/03-evidence-limits/starter`. This time the starter contains a promise its implementation can keep. Your job is to decide whether that promise captures the requirement.

## Inspect the promise

Open `retry_delay_ms` in `src/lib.rs`. The starter promises a delay of at least 100 milliseconds. Its implementation always returns 100.

Before running Ply, answer two separate questions:

- Does that implementation satisfy its current promise?
- Does it satisfy the scheduler's increasing-delay requirement?

Now run:

```sh
cargo ply verify .
```

A passing result is expected. Ply checks the claim it was given. It cannot infer that “at least 100” was intended to mean “double each time.”

Run `cargo test` too. A behavioral test based on the requirement can disagree with a passing check of a weaker promise. That is a useful finding, not an inconsistency between tools.

## Make the requirement precise

The argument is a zero-based retry index. Index zero means the first retry, after the initial failed execution.

| Retry index | Required delay in milliseconds |
| --- | --- |
| 0 | 100 |
| 1 | 200 |
| 2 | 400 |
| 3 and above | 800 |

The delay caps at 800 milliseconds: use index three for any larger argument. This gives every `u8` input a defined answer and avoids an oversized shift. The scheduler's four-attempt limit means its actual retry indices stop at two. Jitter or a different cap would need a new requirement.

Replace the weak postcondition with an equality that expresses this table. Keep the body unchanged for the next run:

```sh
cargo ply verify .
```

This run should find a broken promise. You have improved the specification before repairing the code. If it still passes, inspect whether your new promise distinguishes 100 from the required delay at index one.

Alongside the P0502 report, this run also prints:

```text
Checked again rather than carried forward from an earlier run, because what each one depended on has changed:
  scheduler::retry_delay_ms — the function's own source, its contract and the checks that ran changed since that result was recorded
```

Ply records each function's verified result and reuses it on a later run when nothing that result depends on has changed. Here you changed the contract, so Ply re-checked rather than reusing the earlier passing result, and says so. This record lives in `ply.lock`, next to `Cargo.lock`, along with scratch files Ply generates under `target/ply/`. `.gitignore` already excludes both; there is nothing to check into git.

Then repair the implementation and run:

```sh
cargo test
cargo ply verify .
cargo run
```

Follow the demo's ready times (the trace is the same one shown in [lesson 1](01-first-claim.md)). The queue must also allow other ready work to proceed while a retry is delayed; the shared scheduler tests cover that behavior.

<details>
<summary>Hint</summary>

The table is `100 × 2^min(index, 3)`. Cap the index before shifting; capping a result after an oversized shift is too late. The exact promise should mention the input as well as the result.

</details>

## Report the limit honestly

Your final note should say which delay rule you checked, the 800 ms cap, what evidence ran, and what you did not establish.

For example, these checks do not prove that a real clock is accurate, a worker wakes on time, or retries cannot overwhelm an external service. The application receives a time value; scheduling a wake-up in an operating system is outside this project.

## Check your learning

1. Was the initial passing result false? Explain precisely.
2. Would increasing the number of fuzz cases expose the mismatch while keeping the original promise and constant implementation?
3. Why strengthen the contract and run it before repairing the body?
4. The delay cap is removed. Which input and arithmetic cases must you revisit before accepting the change?

<details>
<summary>Answers and completion criteria</summary>

1. No. The implementation met the weak promise. Treating it as evidence for increasing backoff would be the false conclusion.
2. No. Returning 100 satisfies “at least 100” for every accepted input.
3. The intermediate failure demonstrates that the new claim distinguishes the defect. Repairing both together can hide a claim that still accepts the wrong behavior.
4. Large indices, the integer shift width, and multiplication overflow. The capped function accepts every `u8`; an uncapped replacement cannot silently retain that promise with the same arithmetic.

Keep evidence of all three stages: weak claim passes, stronger claim fails, repaired implementation passes. Explain why each is the right result.

</details>
