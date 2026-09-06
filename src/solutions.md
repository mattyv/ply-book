# Worked solutions

Use these after attempting the exercises. Each `solution` package contains the completed code and can be run with the same commands as its starter.

## 1. Admission

The comparison `active < capacity` is the rule itself. Equality means the queue is full, so `<=` admits one job too many. Always returning false avoids overflow but breaks the requirement to accept work when space remains.

The checkpoint table is: true, true, false, false, false.

Run from `exercises/01-first-claim/solution`:

```sh
cargo test
cargo ply verify .
cargo run
```

A passing contract check supports this predicate. The shared tests provide separate evidence for the queue's handling of it.

## 2. Failure accounting

Increase the count safely, then cap it at the maximum. Saturating arithmetic prevents a wraparound before the cap is applied. The exact postcondition requires progress below the cap and stability at it.

The starter's unchanged count can satisfy a loose upper bound. That is why the repair preserves the exact transition rather than replacing it with “no more than the maximum.”

With a budget of one, the first failure produces a count of one. Eligibility then rejects another attempt.

## 3. Retry delay

`100 * (1u64 << attempt.min(3))` expresses the table and its 800 ms cap for larger indices. The postcondition equates the returned delay to that value. Returning 100 fails it at index one and beyond.

The exercise's important result is the sequence: the original weak claim passes, the exact claim exposes the unchanged implementation, and the repaired code passes the exact claim. More generated cases cannot compensate for a promise that accepts the defect.

## 4. Eligibility

Both conditions must hold: `!cancelled && attempts < max_attempts`.

A useful truth table includes:

| Failed attempts | Maximum | Cancelled | Retry? |
| --- | --- | --- | --- |
| 0 | 1 | false | true |
| 0 | 1 | true | false |
| 1 | 1 | false | false |
| 2 | 1 | false | false |

Use equivalence in the postcondition to require the complete rule. Merely saying that eligible jobs have budget remaining omits cancellation and can also permit rejecting every job.

For the persistence change request, a sound answer distinguishes these checks from new obligations. A crash can lose queued work or cause an already-performed side effect to run again. Recovery tests should interrupt writes and execution at defined points, then verify the agreed restart behavior. The team also needs to decide whether jobs and their external effects can be made idempotent; that is a design decision, not a property established by the current predicate checks.

## What to keep

Keep the repaired implementation, its promises, the requested checks, and useful regression tests. Keep your evidence note too: a later change to the attempt limit or queue model should make its assumptions easy to find.
