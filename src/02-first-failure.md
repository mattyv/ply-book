# 2. Follow a failure back to the code

A job fails. The scheduler must count that attempt before deciding whether to retry. If the count never changes, a failing job can keep returning to the queue.

Work in `exercises/02-first-failure/starter`. Admission is already repaired in this snapshot. Your task is to repair `apply_failure` without changing the attempt policy.

## Define the transition

`attempts` is the number of failed executions already counted. `max_attempts` is the total execution budget. After a failure, the new count is the old count plus one, capped at the maximum.

For a maximum of three:

```text
before: 0  1  2  3
after:  1  2  3  3
```

The last case makes the decision well-defined at the cap. The scheduler should not execute an exhausted job, but the counter still must not wrap around if called there.

Read the `requires` and `ensures` annotations in the starter. A precondition states the inputs under which the promise applies. Ply's generated-input check discards draws outside that condition; a passing result says nothing about those excluded calls.

The application validates its attempt limit when creating a scheduler. That boundary and the function's precondition are different things: an attribute is not a runtime guard for ordinary Rust callers.

## Predict the failure

Read the starter body. For `(attempts = 0, max_attempts = 3)`, calculate what it returns and what the contract requires.

Now trace a job that always fails. If the count stays at zero, what will retry eligibility see after its third execution?

Write your answers, then run:

```sh
cargo ply verify .
```

## Use the counterexample

Read the reported input and the promise that broke. Check the arithmetic by hand. If Ply writes `src/ply_generated_cex.rs`, open it, then run:

```sh
cargo test
```

That generated regression test exercises a concrete input. It is useful after the repair because it prevents the same behavior from slipping back unnoticed. It is not a replacement for the wider contract.

Repair the counter. Preserve the required transition and the precondition, then run:

```sh
cargo test
cargo ply verify .
cargo run
```

Follow the failure count in the demo and read the bounded-retry test in the shared scheduler. The contract checks the local arithmetic; that test checks that the application uses it to stop retrying.

<details>
<summary>Hint</summary>

Use the standard integer operations to increase the count safely and cap it. Check both an ordinary failure and an already-capped input. Avoid arithmetic that wraps before applying the cap.

</details>

## Distinguish three outcomes

A counterexample means a checked input broke a promise. A compiler error means the check could not run successfully. A missing engine or unsupported input means the requested evidence was not earned. These need different repairs.

The exit status is a useful gate, but the explanation tells you what happened. Do not count any nonzero exit as a successful reproduction of this exercise's bug.

## Check your learning

1. A proposed repair changes the contract to “the result is at most the maximum” and leaves the body unchanged. Why can that pass while the retry bug remains?
2. Why does a limit of one permit no retry after the first failure?
3. A precondition excludes an input. Does that protect an ordinary caller from supplying it?
4. A regression test passes after your repair. What extra evidence does running Ply again request?

<details>
<summary>Answers and completion criteria</summary>

1. An unchanged count can remain below the maximum forever. The weaker promise loses the required progress.
2. The failed initial execution consumes the only attempt. The count becomes one, so the budget is exhausted.
3. No. The caller or an explicit runtime boundary must enforce the input rule.
4. Generated-input checking against the contract, beyond that one recorded counterexample. It still has a finite scope.

Finish with passing tests and verification, and a written explanation connecting the counter repair to the application's retry limit.

</details>
