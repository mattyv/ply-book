#!/usr/bin/env bash
set -euo pipefail

ply_bin=${PLY_BIN:-${1:-cargo-ply}}
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

starter="$tmp/missed-input/starter"
mkdir -p "$starter" "$tmp/scheduler"
cp "$root/exercises/05-missed-input/starter"/{Cargo.toml,Cargo.lock,ply.yaml} "$starter/"
cp -R "$root/exercises/05-missed-input/starter/src" "$starter/src"
cp -R "$root/exercises/scheduler/src" "$tmp/scheduler/src"

"$ply_bin" render "$starter" --output "$tmp/intent.svg"
if (cd "$starter" && "$ply_bin" verify . --json --publish-view --svg "$tmp/failed.svg") >"$tmp/failed.json"; then
  echo "broken starter unexpectedly verified" >&2
  exit 1
fi

python3 - "$tmp/failed.json" "$tmp/intent.svg" "$tmp/failed.svg" "$starter" <<'CHECK_FAILED'
import json, sys
import xml.etree.ElementTree as ET
from pathlib import Path

result = json.loads(Path(sys.argv[1]).read_text())
node = result["root"]["children"][0]["children"][0]
assert node["id"] == "retry_delay_ms" and node["verdict"] == "violation", node
diagnostic, = [d for d in result["diagnostics"] if d.get("node_id") == "scheduler::retry_delay_ms"]
assert diagnostic["code"] == "P0502", diagnostic
assert int(diagnostic["counterexample"]["inputs"]["attempt"]) >= 58, diagnostic
assert (Path(sys.argv[4]) / diagnostic["counterexample"]["cargo_test"]).is_file(), diagnostic
intent, failed, starter = map(Path, sys.argv[2:])
assert intent.read_text().startswith("<svg") and "retry_delay_ms" in intent.read_text()
root = ET.parse(failed).getroot()
assert any("fn-chip-box-violated" in e.get("class", "").split() for e in root.iter())

index = json.loads((starter / "target/ply/view.json").read_text())
assert index["protocolVersion"] == 1
run, = [r for r in index["runs"] if r["id"] == index["currentRun"] and r["outcome"] == "violation"]
view = json.loads((starter / "target/ply" / run["path"]).read_text())
assert view["protocolVersion"] == 1 and view["run"]["outcome"] == "violation"
fn, = [e for e in view["elements"].values() if e["kind"] == "fn" and e["label"] == "retry_delay_ms"]
assert fn["declaration"] == "Postcondition (ensures): |result|*result == 100 *(1u64 << attempt.min (3))"
assert fn["evidence"]["verdict"] == "violation" and fn["source"]["file"] == "src/lib.rs"
assert any(d["code"] == "P0502" and d["elementId"] == fn["id"] for d in view["diagnostics"])
CHECK_FAILED

python3 - "$starter/src/lib.rs" <<'REPAIR'
from pathlib import Path
import sys

path = Path(sys.argv[1])
source = path.read_text()
old = "(100 * (1u64 << attempt)).min(800)"
assert source.count(old) == 1
path.write_text(source.replace(old, "100 * (1u64 << attempt.min(3))"))
REPAIR

(cd "$starter" && cargo test)
(cd "$starter" && "$ply_bin" verify . --json --publish-view --svg "$tmp/repaired.svg") >"$tmp/repaired.json"

python3 - "$tmp/repaired.json" "$tmp/repaired.svg" "$starter" <<'CHECK_REPAIRED'
import json, sys
import xml.etree.ElementTree as ET
from pathlib import Path

result = json.loads(Path(sys.argv[1]).read_text())
node = result["root"]["children"][0]["children"][0]
assert node["id"] == "retry_delay_ms" and node["verdict"] == "fuzzed(64)", node
assert node["evidence"]["engine"] == "proptest" and node["evidence"]["cases"] == 64, node
assert not result["diagnostics"], result
svg, starter = map(Path, sys.argv[2:])
root = ET.parse(svg).getroot()
assert any("fn-chip-box-earned" in e.get("class", "").split() for e in root.iter())
assert "1 earned" in svg.read_text()

index = json.loads((starter / "target/ply/view.json").read_text())
run, = [r for r in index["runs"] if r["id"] == index["currentRun"] and r["outcome"] == "clean"]
view = json.loads((starter / "target/ply" / run["path"]).read_text())
fn, = [e for e in view["elements"].values() if e["kind"] == "fn" and e["label"] == "retry_delay_ms"]
assert view["run"]["outcome"] == "clean" and not view["diagnostics"]
assert fn["evidence"]["verdict"] == "fuzzed(64)" and fn["evidence"]["engine"] == "proptest"
assert fn["evidence"]["seed"] == node["evidence"]["seed"] and fn["source"]["file"] == "src/lib.rs"
CHECK_REPAIRED
