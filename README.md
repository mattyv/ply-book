# The Ply Book

Learn Ply by building a job scheduler in Rust. Three guided lessons and an independent challenge cover writing contracts, repairing failures, and recognizing the limits of passing evidence.

[Read the book](https://mattyv.github.io/ply-book/) · [Start locally](src/setup.md)

The exercises share a working in-memory scheduler with a bounded queue, delayed retries, and cancellation. Each lesson has a starter and a worked solution. Short checkpoints ask you to explain the result as well as repair the code.

## Run an exercise

Follow the [setup instructions](src/setup.md) to install the pinned Ply revision, then:

```sh
cd exercises/01-first-claim/starter
cargo test
cargo ply check .
cargo ply verify .
```

The starter's tests and verification deliberately fail. Repair the admission decision as described in [lesson 1](src/01-first-claim.md), then run `cargo run` to see it used by the scheduler.

## Check and preview the course

Use Rust 1.98.0 and the same Ply revision as the exercises:

```sh
cargo install --git https://github.com/mattyv/ply \
  --rev 0ae6f7d37b6a385e7b1283a0d43e0d1c2cb586d9 --locked ply-cli
cargo install mdbook --version 0.5.4 --locked
bash scripts/check-exercises.sh
mdbook build
mdbook serve --open
```

The checker works on temporary copies, including expected failures, so it does not repair or modify learners' source files. Update the command and dependency pins together when changing Ply versions, then run the full course check and review the lesson explanations.

## Publish

The GitHub Actions workflow checks the exercises and builds the book for pull requests. Successful runs on `main` publish to GitHub Pages. Set **Settings → Pages → Build and deployment → Source** to **GitHub Actions** for the repository.

The book uses native [mdBook](https://rust-lang.github.io/mdBook/) pages and expandable answers, with the official [GitHub Pages workflow](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages). Exercises run locally; the website does not execute Rust or Ply.

## Scope

This first course assumes basic Rust. It teaches a single-threaded scheduler; persistence, concurrent workers, and exactly-once side effects remain outside its claims. See the [project requirements](src/project.md).

Licensed under the [MIT license](LICENSE).
