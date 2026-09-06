# Where to go next

You have practiced four different jobs: implementing a precise requirement, repairing a counterexample, improving a claim that was too weak, and finding an input the examples missed. The independent challenge adds the task of choosing evidence yourself.

Before applying Ply to a larger project, pick one small decision in real code. Write its requirement in plain language, identify the inputs under which it must hold, and choose a promise that would reject a plausible bug. Then run the available checks and record their limits.

Use the [Ply reference](https://github.com/mattyv/ply/blob/0ae6f7d37b6a385e7b1283a0d43e0d1c2cb586d9/docs/SCHEMA.md) for declarations and the [pinned Ply README](https://github.com/mattyv/ply/blob/0ae6f7d37b6a385e7b1283a0d43e0d1c2cb586d9/README.md) for the wider workflow.

## Possible later courses

Persistence would introduce recovery and duplicate execution. Concurrency would introduce ownership and interleavings. Architecture checks would introduce component boundaries and the difference between declared structure and the dependency facts Ply can inspect.

Those topics deserve separate exercises with working implementations and explicit evidence. This first course does not claim to cover them.

## Help improve this course

If an exercise behaves differently from its explanation, record the course revision, the command, and the full result in a [course issue](https://github.com/mattyv/ply-book/issues). State whether the mismatch concerns setup, behavior, or interpretation. Avoid including private paths, credentials, or job data.
