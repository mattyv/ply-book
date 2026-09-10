# Set up your workshop

The website is your textbook. Run Rust and Ply on your own machine; GitHub Pages serves the book and does not execute the exercises.

## Get the project

Install [Rust through rustup](https://www.rust-lang.org/tools/install), then clone the course:

```sh
git clone https://github.com/mattyv/ply-book.git
cd ply-book
rustup toolchain install 1.98.0 --profile minimal
```

The repository's `rust-toolchain.toml` selects Rust 1.98.0. Install the course's pinned Ply 0.2.0 command:

```sh
cargo install --git https://github.com/mattyv/ply \
  --rev 66342cb02ab876326f6ca53360e5b440c3d950d1 --locked ply-cli
cargo ply --version
cargo ply --help
```

Running that command from inside the cloned repository prints this warning:

```text
warning: default toolchain implicitly overridden with `1.98.0-x86_64-unknown-linux-gnu` by rustup toolchain file
  = help: use `cargo +stable install` if you meant to use the stable toolchain
  = note: rustup selects the toolchain based on the parent environment and not the environment of the package being installed
```

This warning confirms that Rust builds Ply with the course's pinned toolchain.

If Cargo reports another `ply-cli` installation, decide whether to replace it, then repeat the installation with `--force`. The exercise manifests already pin the matching attribute dependency. Keep both pins together when upgrading the course.

You need an internet connection for the initial downloads. These lessons use `fuzz` checks and ordinary tests; they do not require Kani or a mutation-testing installation.

## Find your first exercise

```sh
cd exercises/01-first-claim/starter
cargo test
cargo ply check .
cargo ply verify .
```

The starter is deliberately incomplete. `cargo test` fails outright: all five tests fail, not only the lesson's own admission test. Four of the five live in `scheduler::tests`, the shared queue's own tests, and they fail too, because `can_claim` always returns `false`, so nothing is ever admitted and nothing downstream has anything to work with. That is not a broken scheduler; it is one unrepaired decision failing every test that depends on it. The failure is the starting point of lesson 1, not an installation check that must be green. A compiler error, missing command, or download failure is a setup problem; a reported broken postcondition is the intended finding.

Each lesson has `starter` and `solution` packages. Work in the starter. Later chapters begin with earlier decisions already repaired, so you can resume without copying files between chapters. A starter also contains working bodies for functions that belong to later lessons, so the shared scheduler still runs end to end; those functions carry no `requires` or `ensures` yet, so you will not see a later lesson's promise before you reach it. The shared scheduler source lives in `exercises/scheduler/src/`.

## Learn the commands

| Command | What it establishes |
| --- | --- |
| `cargo test` | The ordinary Rust tests that ran passed or failed |
| `cargo ply check .` | The declaration is valid and the available structural checks ran; it does not run the contract checks |
| `cargo ply verify .` | The requested checks ran, or Ply reports why evidence could not be earned |
| `cargo ply render . -o intent.svg` | Draws the YAML declaration without gathering evidence |
| `cargo ply verify . --publish-view --svg run.svg` | Runs checks, saves an evidence drawing, and publishes a local snapshot for Ply Visual |

Ply's [contract](glossary.md#contract) attributes do not add runtime assertions to an ordinary Rust build. A passing `cargo test` therefore does not, by itself, say that those contracts were checked. After a verification failure, Ply can also generate an ordinary [regression test](glossary.md#regression-test) from the counterexample; that test does run under Cargo.

`cargo ply --help` and `cargo ply explain` cite section marks such as `§6`, `§8`, and `The-Ply-Spec.md §5.4c`. Those refer to sections of Ply's own specification, not this book. See [`The-Ply-Spec.md`](https://github.com/mattyv/ply/blob/66342cb02ab876326f6ca53360e5b440c3d950d1/The-Ply-Spec.md) at the pinned revision if you want that reasoning in full.

## Keep the failure evidence

Verification can create `src/ply_generated_cex.rs` and connect it to the crate's tests. Connecting it means an appended line, `mod ply_generated_cex;`, at the end of `src/lib.rs`; expect to see that line and the new file together in `git status`. The first `verify` in a fresh checkout can also update `Cargo.lock` to add the generated harness's own dependencies. Neither change alters the code you wrote.

Read `src/ply_generated_cex.rs` when it appears. It records a concrete failure that you can reproduce while repairing the code. Do not delete it merely to make `cargo test` pass.

Generated checking [harnesses](glossary.md#harness) under `target/ply/` are scratch files. Fix your source rather than editing a harness.

## Preview the book locally (optional)

From the repository root:

```sh
cargo install mdbook --version 0.5.4 --locked
mdbook serve --open
```

You do not need mdBook to do the exercises.
