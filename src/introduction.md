# Learn Ply by building a job scheduler

A job scheduler accepts work, chooses what runs next, and decides what to do when a job fails. A small mistake can lose work, fill a queue beyond its limit, or retry a failing job forever.

In this course, you will build and repair those decisions in ordinary Rust. You will use Ply to state what they must do, find inputs that break those promises, and examine what a passing check actually establishes.

You should already be comfortable with Rust functions, structs, `Option`, `Result`, and unit tests. You do not need experience with verification tools. This is a course about using Ply, rather than an introduction to Rust.

## What you will make

The companion project is a single-threaded, in-memory scheduler with a bounded queue, delayed retries, and cancellation. Each lesson provides a snapshot of the same application. The queue and execution code are shared; you change the policy a chapter asks you to investigate.

The command-line demo uses those policies to run jobs. Ordinary Rust tests check queue behavior. Ply checks the promises you attach to individual decisions. You will learn why each kind of check is useful and where it stops.

| Lesson | Your work | What you should be able to explain afterward |
| --- | --- | --- |
| 1. First claim | Implement the queue admission rule | How a requirement becomes a contract |
| 2. First failure | Repair the attempt counter | How a counterexample guides a repair |
| 3. Passing result | Expose and strengthen a weak delay promise | Why passing evidence can support the wrong requirement |
| 4. Missed input | Investigate passing tests and a failing generated check | How checking a property finds cases the examples miss |
| 5. Independent challenge | Complete the retry eligibility rule | How to choose claims and defend their scope |

Allow about 30–45 minutes for each lesson and an hour for the challenge, plus installation time. These are planning estimates, not time limits.

## How to work through a lesson

Before you run a command, write down what you expect it to tell you. Then run it, inspect the result, and explain the difference. Keep a short notebook containing your prediction, one piece of evidence, and one limit of that evidence.

Try an exercise before opening its hint. Finish the checkpoint before reading its answers. The worked solutions explain the reasoning as well as the code, but they are most useful after you have committed to your own answer.

A chapter is complete when you can explain the result. Some starter exercises are supposed to fail. Lesson 3 begins with a passing check of a weak promise; lesson 4 begins with passing tests that miss a broken promise.

## The version matters

Ply is in early development. This course pins its command and attributes to one revision so the exercises have a reproducible reference point. Use the installation commands in the next page; a newer Ply may behave differently.
