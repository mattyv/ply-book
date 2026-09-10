# The Ply Book

Learn Ply by building a job scheduler in Rust. Four guided lessons and an independent challenge cover writing [contracts](src/glossary.md#contract), repairing failures, and recognizing the limits of passing [evidence](src/glossary.md#earned-evidence).

[Read the book](https://mattyv.github.io/ply-book/) · [Start locally](src/setup.md) · [Glossary](src/glossary.md)

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

Use Rust 1.98.0 and the pinned Ply 0.2.0 revision shared by the exercises:

```sh
cargo install --git https://github.com/mattyv/ply \
  --rev 66342cb02ab876326f6ca53360e5b440c3d950d1 --locked ply-cli
cargo install mdbook --version 0.5.4 --locked
bash scripts/check-exercises.sh
bash scripts/check-visuals.sh
mdbook build
mdbook serve --open
```

The checks use temporary copies and include the lessons' expected failures. They leave learners' source files untouched. When upgrading Ply, update the command, exercise manifests and lockfiles, reference links, and CI installation to the same revision. Then run both checks and review the lesson explanations.

## Publish

Push the pinned Ply commit to its public repository before publishing a book update that depends on it. The GitHub Actions workflow installs that revision, checks the exercises and visual walkthrough, and builds the book for pull requests. Successful runs on `main` publish to GitHub Pages. Set **Settings → Pages → Build and deployment → Source** to **GitHub Actions** for the repository.

The book uses native [mdBook](https://rust-lang.github.io/mdBook/) pages and expandable answers, with the official [GitHub Pages workflow](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages). Exercises run locally; the website does not execute Rust or Ply.

## Scope

This first course assumes basic Rust. It teaches a single-threaded scheduler; persistence, concurrent workers, and exactly-once side effects remain outside its claims. See the [project requirements](src/project.md).

Licensed under the [MIT license](LICENSE).
