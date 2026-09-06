# 4. Independent challenge: cancellation and retries

You have inherited the scheduler with admission, failure accounting, and backoff repaired. Finish its retry eligibility decision without copying the worked solution.

Work in `exercises/04-retry-eligibility/starter`. Read `is_retry_eligible`, its existing declaration, and the caller in the shared scheduler.

## Your brief

A job may be retried exactly when it has not been cancelled and its attempt count is below the configured maximum. The initial execution counts toward that maximum.

An available budget must not override cancellation. Cancellation must not create extra attempts. The rule should define an answer at and above the limit as well as below it.

The queue removes a cancelled pending job. The decision's cancellation argument also makes the retry rule explicit for callers: a cancelled job is ineligible regardless of its count. Consider both responsibilities when choosing your tests.

## Deliverables

1. Write a small truth table covering cancellation and the attempt boundary.
2. Express the complete requirement as a postcondition and request a generated-input check in `ply.yaml`. The starter deliberately leaves this annotation for you to write.
3. Demonstrate that your chosen check rejects the starter defect. Preserve the finding or counterexample.
4. Repair the implementation and run ordinary tests, Ply verification, and the demo.
5. Write a short review: what was checked, what passed, and which application-level properties remain outside that evidence.

Choose your own examples before reading a hint. Include at least one cancelled job with budget remaining and one uncancelled job with no budget remaining.

<details>
<summary>Hint: separate the decisions</summary>

Write down “not cancelled” and “budget remains” as two booleans. A retry requires both. An `or` would let one condition override the other.

</details>

## A change request

A teammate proposes saving jobs to disk so they survive restarts. They point to your passing checks and say the scheduler is ready for production.

Write a response of no more than five sentences. Identify at least two new failure modes and one kind of evidence you would request before accepting persistence. Do not implement persistence for this challenge.

## Assess your work

| Criterion | Ready | Revisit |
| --- | --- | --- |
| Requirement | Both cancellation and budget appear in the claim | One condition can override or omit the other |
| Reproduction | A reported broken promise exposes the starter defect | Only a compiler error or unrelated failure is shown |
| Repair | Tests and verification pass without weakening the requirement | Tests or claims were removed to obtain a pass |
| Application | You can trace the rule through failure and cancellation | Only the boolean expression was considered |
| Evidence | The scope and remaining risks are stated | A passing predicate is presented as proof of the whole scheduler |

There is no numerical score. Any “revisit” identifies the next piece of work. When every row is ready, compare your reasoning with the worked solutions.
