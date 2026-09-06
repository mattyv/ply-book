#!/usr/bin/env bash
set -euo pipefail

ply_bin=${1:-cargo-ply}
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export CARGO_TARGET_DIR="$tmp/target"
cp -R "$root/exercises/scheduler" "$tmp/scheduler"

run() { local dir=$1; shift; (cd "$dir" && "$@"); }
copy() { local name=$1; cp -R "$root/exercises/$name" "$tmp/$name"; printf '%s\n' "$tmp/$name"; }
expect_test_fail() { if "$@" >"$tmp/out" 2>&1; then cat "$tmp/out"; return 1; fi; grep -q 'test result: FAILED' "$tmp/out"; }
verify_json() {
  local dir=$1 target=$2 expected=$3 success=$4 rc
  if run "$dir" "$ply_bin" verify . --json >"$tmp/out" 2>&1; then rc=0; else rc=$?; fi
  if [ "$success" = yes ] && [ "$rc" -ne 0 ]; then cat "$tmp/out"; return 1; fi
  if [ "$success" = no ] && [ "$rc" -eq 0 ]; then cat "$tmp/out"; return 1; fi
  python3 - "$tmp/out" "$target" "$expected" <<'CHECK'
import json, sys
with open(sys.argv[1]) as source:
    result = json.load(source)
stack = [result["root"]]
found = []
while stack:
    node = stack.pop()
    stack.extend(node.get("children", []))
    if node.get("kind") == "fn" and node.get("id") == sys.argv[2]:
        found.append(node)
assert len(found) == 1, (sys.argv[2], found)
assert found[0]["verdict"] == sys.argv[3], result
if sys.argv[3] == "fuzzed(64)":
    assert found[0]["evidence"]["cases"] == 64, found[0]
print(sys.argv[2], sys.argv[3])
CHECK
}

for stage in 01-first-claim 02-first-failure 03-evidence-limits 04-retry-eligibility; do
  dir=$(copy "$stage")
  expect_test_fail run "$dir/starter" cargo test
  if [ "$stage" = 04-retry-eligibility ]; then
    # The independent challenge asks learners to author this instructor contract
    # and to request a check for it in ply.yaml; the starter deliberately leaves
    # both undone (an empty checks: list, and no #[ply::ensures]).
    python3 - "$dir/starter/src/lib.rs" "$dir/starter/ply.yaml" <<'CONTRACT'
from pathlib import Path
import sys
lib_path, yaml_path = Path(sys.argv[1]), Path(sys.argv[2])
source = lib_path.read_text()
marker = "// TODO: write the complete retry eligibility postcondition."
assert source.count(marker) == 1
lib_path.write_text(source.replace(marker, "#[ply::ensures(|result| *result == (!cancelled && attempts < max_attempts))]"))
declaration = yaml_path.read_text()
empty_checks = "is_retry_eligible:\n        checks: []"
assert declaration.count(empty_checks) == 1
yaml_path.write_text(declaration.replace(empty_checks, "is_retry_eligible:\n        checks: [fuzz(64)]"))
CONTRACT
  fi
  run "$dir/starter" "$ply_bin" check .
  if [ "$stage" = 03-evidence-limits ]; then
    verify_json "$dir/starter" retry_delay_ms 'fuzzed(64)' yes
    perl -0pi -e 's/\*result >= 100/\*result == 100 * (1u64 << attempt.min(3))/' "$dir/starter/src/lib.rs"
    verify_json "$dir/starter" retry_delay_ms violation no
  else
    case "$stage" in
      01-first-claim) target=can_claim ;;
      02-first-failure) target=apply_failure ;;
      04-retry-eligibility) target=is_retry_eligible ;;
    esac
    verify_json "$dir/starter" "$target" violation no
  fi
  # A generated regression test must actually compile and run, not just get
  # written to disk -- this is the step that would have caught the lesson 2
  # generated test failing to compile.
  expect_test_fail run "$dir/starter" cargo test
  run "$dir/solution" cargo test
  run "$dir/solution" cargo run --quiet
  run "$dir/solution" "$ply_bin" check .
  case "$stage" in
    01-first-claim) target=can_claim ;;
    02-first-failure) target=apply_failure ;;
    03-evidence-limits) target=retry_delay_ms ;;
    04-retry-eligibility) target=is_retry_eligible ;;
  esac
  verify_json "$dir/solution" "$target" 'fuzzed(64)' yes
done

# Ordinary tests miss the arithmetic panic; verification supplies its witness.
dir=$(copy "05-missed-input")
run "$dir/starter" cargo test
run "$dir/starter" cargo run --quiet
run "$dir/starter" "$ply_bin" check .
verify_json "$dir/starter" retry_delay_ms violation no
python3 - "$tmp/out" "$dir/starter" <<'PANIC'
import json, sys
from pathlib import Path
result = json.loads(Path(sys.argv[1]).read_text())
diagnostics = [d for d in result["diagnostics"] if d.get("node_id") == "scheduler::retry_delay_ms"]
assert len(diagnostics) == 1, diagnostics
diagnostic = diagnostics[0]
assert diagnostic["code"] == "P0502", diagnostic
assert diagnostic["engine"] == "proptest" and diagnostic["check"] == "fuzz(64)", diagnostic
assert "panicked before its postcondition" in diagnostic["title"], diagnostic
witness = diagnostic["counterexample"]
assert 58 <= int(witness["inputs"]["attempt"]) <= 255, witness
assert witness["cargo_test"] == "src/ply_generated_cex.rs", witness
assert (Path(sys.argv[2]) / witness["cargo_test"]).is_file(), witness
PANIC
expect_test_fail run "$dir/starter" cargo test
expect_test_fail run "$dir/starter" cargo test ply_cex_retry_delay_ms_01
python3 - "$dir/starter/src/lib.rs" <<'REPAIR'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
body = "(100 * (1u64 << attempt)).min(800)"
assert source.count(body) == 1
path.write_text(source.replace(body, "100 * (1u64 << attempt.min(3))"))
REPAIR
run "$dir/starter" cargo test
verify_json "$dir/starter" retry_delay_ms 'fuzzed(64)' yes
run "$dir/solution" cargo test
run "$dir/solution" cargo run --quiet
run "$dir/solution" "$ply_bin" check .
verify_json "$dir/solution" retry_delay_ms 'fuzzed(64)' yes
