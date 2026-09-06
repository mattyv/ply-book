# 4. Find an input the tests missed

A teammate rewrites the retry delay after lesson 3. The requirement stays the same: 100 milliseconds, then 200, then 400, with an 800 millisecond cap for every larger index. The tests pass. The scheduler demo runs.

Would you accept the change?

Work in `exercises/05-missed-input/starter`. This exercise begins with passing ordinary tests. Keep that starting point: run them before adding a regression test or running Ply.

## Read the proposed change

The earlier implementation capped the index before calculating the delay. The new version caps the result:

```rust,ignore
(100 * (1u64 << attempt)).min(800)
```

On paper, both expressions describe capped exponential growth. Rust evaluates them with fixed-width integers. Each intermediate operation must be valid before `.min(800)` can run.

Open `src/lib.rs`. Read the existing test's inputs and the postcondition above `retry_delay_ms`. The tests cover indices zero through three; the promise covers every `u8` value. There is no `requires` clause excluding larger indices.

## Predict, then run

Write down the answers to these questions:

1. Which inputs do the ordinary delay tests exercise?
2. Which inputs does the function promise to handle?
3. Can a cap applied at the end protect an earlier calculation?

Then run:

```sh
cargo test
cargo run
cargo ply check .
```

All three should succeed. The shared scheduler tests pass too: its attempt budget only exercises small retry indices. These results establish useful behavior, but they do not cover the function's whole input domain.

For the [Read the evidence walkthrough](read-the-evidence.md), first save the declaration with `cargo ply render . -o intent.svg`. The next command captures the failing visual before you repair anything.

Now request generated inputs against the existing promise:

```sh
cargo ply verify . --publish-view --svg failed.svg
```

Read the finding before changing the code. In the reference run against the course's pinned Ply revision, `retry_delay_ms` reports a violation with a shrunk input of `attempt = 58`: the multiplication overflows. Your run may report a different failing input. An installation failure or a harness that could not compile is not the intended result.

## Explain the disagreement

There are two arithmetic hazards. Multiplication by 100 can overflow a `u64` even when the shift itself fits. At index 64, the shift also exceeds the width of that integer. Neither hazard is reached by the four small examples.

The starter's ordinary tests were green because their inputs missed the defect. Ply's generated-input check explores beyond those examples. It is still a finite run, rather than proof that every possible bug has been found.

This lesson and lesson 3 expose different gaps:

| Lesson | What was missing? | What changes? |
| --- | --- | --- |
| Weak promise | The claim accepted incorrect behavior | Strengthen the claim, then repair the code |
| Missed input | The examples never reached the failing calculation | Keep the claim, extend the tests, and repair the code |

## Preserve the discovery

The reference run writes `src/ply_generated_cex.rs` and connects it to the crate's tests. Open that file. Find the failing input, the call to the real function, and the assertion or panic that reproduces the finding.

Now run the ordinary tests again, before repairing anything:

```sh
cargo test
```

They should now fail. The original examples still pass; the generated regression reaches the missed case. Ply has turned its discovery into a test that Cargo can run without a verification engine.

If your run did not generate that file, inspect the diagnostic before continuing. Do not substitute an unrelated compiler error for the expected arithmetic failure.

Keep the regression test while repairing the code. The solution also checks index 64 and `u8::MAX`, both of which must return 800. Those are examples you can add after the discovery; putting them in the starter would hide the coverage gap this lesson is meant to expose.

Repair the calculation while preserving the requirement, then run:

```sh
cargo test
cargo ply verify .
cargo run
```

<details>
<summary>Hint</summary>

Limit the index before shifting. For the 800 millisecond cap, every index above three uses the same calculation as index three. Changing to wrapping arithmetic would change the result, not meet the promise.

</details>

## Keep the scope honest

The current scheduler allows at most four attempts and never supplies the large input that exposes this defect. You have found a failure of the public delay function's broader contract, not demonstrated that today's scheduler crashes during normal retries.

That distinction matters. A smaller input contract could be a legitimate design choice in a different project, provided every caller upholds it. In this course, the requirement explicitly covers every `u8`; adding a precondition to hide large indices would change that requirement.

Ordinary tests could have caught the same problem if someone had chosen those inputs. Ply's contribution here is to search for them against a stated property, rather than require the author to anticipate each example.

Before finishing, complete [Read the evidence](read-the-evidence.md): compare the saved failure with a newly published repaired run, inspect the function, and explain what its evidence leaves unchecked.

## Check your learning

1. Why did the starter's ordinary tests pass?
2. Why is “the result is capped at 800” an inadequate explanation of arithmetic safety?
3. Would a `requires(attempt <= 3)` annotation repair this exercise?
4. Does the finding show that the current scheduler reaches the failing input?
5. What should remain in the repository after the repair?

<details>
<summary>Answers and completion criteria</summary>

1. They exercised small indices whose intermediate calculations fit. The shared scheduler tests also used only its small, supported attempt budgets.
2. The shift and multiplication happen before the result cap. A later operation cannot rescue an earlier overflow. The reference failure at 58 comes from multiplication; 64 also exceeds the shift width.
3. No. It would exclude inputs the requirement says must work. Revising that requirement would be a separate decision.
4. No. The function's promised domain is wider than the current caller's reachable inputs.
5. The repaired calculation, unchanged full-domain promise, requested checks, and a regression test for the discovered gap.

Finish with three recorded observations: the original tests pass, Ply detects a missed case, and the repaired implementation passes both the extended tests and verification.

</details>
