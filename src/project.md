# The scheduler we will build

Imagine a small service that accepts background jobs: prepare a report, send an export, or refresh an index. A caller submits a job, and a worker takes it when it is ready. If the work fails, the scheduler may put it back in the queue.

Our project implements that scheduling behavior in memory. The command-line demo drives it with example jobs; you can follow a job through admission, execution, failure, and retry.

## Requirements

These are the requirements for every lesson. Repair the implementation to meet them. If you discover a problem with a requirement, record it separately instead of silently changing the promise.

1. The pending queue has a fixed, positive capacity. Admit a job only when the number of pending jobs is below that capacity. Reject duplicate IDs already pending.
2. Run ready jobs in their queue order. A delayed job must not block a later job that is ready now.
3. Count each failed execution. After a failure, increase the attempt count by one, up to the configured maximum.
4. Permit at most one to four attempts in total. The initial execution counts as an attempt; a limit of one allows no retry after a failure.
5. Wait 100 milliseconds before the first retry, then 200, then 400. Cap the delay at 800 milliseconds for index 3 and above. The four-attempt scheduler never reaches that cap, but the decision remains defined for larger indices.
6. A cancelled job must not run again. A job whose attempt budget is exhausted must not be retried.

The scheduler receives the current time as an argument. This lets tests advance time without sleeping and makes the choice of ready work reproducible.

## Where the lessons fit

| Decision | Inputs | Required result |
| --- | --- | --- |
| Admission | Pending count and capacity | Is there room for one more job? |
| Failure accounting | Failure count and maximum attempts | What is the next capped failure count? |
| Retry delay | Zero-based retry index | How long before this retry becomes ready? |
| Retry eligibility | Failure count, maximum attempts, cancellation | May this job be queued again? |

The shared queue calls the decisions you edit. They are small enough for Ply to generate inputs for, but they sit on the actual execution path. You will also run scheduler tests because a correct decision can still be called at the wrong time or with the wrong arguments.

## What this first course leaves out

The scheduler has one owner and runs in one process. It does not save jobs across restarts, run workers concurrently, or promise that an external side effect happens exactly once. A crash after sending an export but before recording completion would need a design beyond this project.

Keep that [boundary](glossary.md#boundary) in your final assessment. Passing checks for this scheduler cannot establish those properties.
