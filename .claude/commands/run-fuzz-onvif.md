# /run-fuzz-onvif — one Ralph iteration against the ONVIF parser fuzz harness

Run a single iteration of the ONVIF parser fuzz loop. Pair with `/loop` to self-pace.

## Per-iteration prompt

You are running one iteration of a Ralph loop against `swift-onvif`'s ONVIF response parsers.

### 1. Snapshot the failures dir BEFORE running

```bash
cd ~/swift-onvif
ls tests/fuzz/failures/ 2>/dev/null | sort > /tmp/fuzz-snapshot-before.txt
```

### 2. Run the fuzz suite

```bash
swift test --filter CapabilitiesFuzzTests 2>&1 | tail -20
```

### 3. Diff the failures dir

```bash
ls tests/fuzz/failures/ 2>/dev/null | sort > /tmp/fuzz-snapshot-after.txt
diff /tmp/fuzz-snapshot-before.txt /tmp/fuzz-snapshot-after.txt | grep "^>" | sed 's/^> //'
```

If zero new entries: **EXIT SUCCESS** for this iteration. If 10 consecutive iterations report success, the loop converges — stop the loop.

### 4. Pick the FIRST new failure

For each new entry under `tests/fuzz/failures/<timestamp>-<parser>-<mutator>-<mode>/`:
- Read `report.txt` for the failure mode (F1 crash / F2 silent fail-open / F3 false reject) and detail
- Read `input.xml` for the mutated input that triggered the failure
- The directory name encodes parser + mutator: `parseCapabilities-NamespaceSwapTtToAlt-F2-SilentFailOpen` → fix `parseCapabilities` so the `NamespaceSwapTtToAlt` mutator no longer produces a silent fail-open

### 5. Write a minimal fix

- Locate the parser at `Sources/SwiftONVIF/Services/DeviceService.swift`
- Make the smallest change that resolves the failure mode without breaking other tests
- Common fixes:
  - **F2 (silent fail-open) on namespace-swap mutators:** parser hard-codes a namespace prefix; replace with prefix-tolerant matching
  - **F2 on truncate/drop mutators:** parser silently returns empty struct on broken input; add an explicit check that throws when required fields are absent across the WHOLE response
  - **F3 (false reject) on benign mutators:** parser too strict; relax to handle the variation
- Do NOT add error handling for impossible scenarios. Surgical changes only.

### 6. Verify the fix

```bash
swift test --filter CapabilitiesFuzzTests 2>&1 | tail -10
```

If the targeted failure no longer appears AND no pre-existing tests break: proceed to commit.
If a pre-existing test breaks: **ABORT** — revert the change and surface the regression.
If the same failure recurs after 3 attempted fixes for this mutator: **ESCALATE** — the loop isn't converging on this case.

### 7. Commit

```bash
git add Sources/SwiftONVIF/Services/DeviceService.swift tests/fuzz/failures/
git commit -m "fuzz: handle <Mutator> in parseCapabilities (iter N)

Failure: <failure mode> when <one-line description of mutator behavior>
Fix: <one-line description of the change>"
```

Do NOT push. The /loop runs locally; pushing happens after convergence (or CAP) when a human reviews the squashed PR.

### 8. Done — return to /loop for the next iteration

The next iteration will re-run the test suite and look for a new failure to fix.

---

## Exit conditions (the /loop driver enforces)

- **SUCCESS:** 10 consecutive iterations with zero new failures.
- **CAP:** 50 iterations total. Force human review.
- **ESCALATE:** same failure recurs after 3 attempted fixes.
- **ABORT:** any commit breaks a pre-existing test. Revert and stop.

## Adding new mutators

When the existing 3 mutators converge to clean, expand the surface:

1. Add a new `Mutator(...)` to `Self.mutators` in `Tests/SwiftONVIFTests/CapabilitiesFuzzTests.swift`
2. Decide its category: `.destructive` (parser must reject) vs `.benign` (parser must still extract)
3. Add a `testFuzzParseDeviceInformation` test wired to the same mutator list against `parseDeviceInformation`
4. Re-run the loop

## Adding real-camera seed corpus

The synthetic `get-capabilities-response.xml` covers the happy path. To find vendor-specific bugs:

1. Capture real responses from Q6325-LE / Q6358-LE / P3285-LVE using the `ONVIFExplorer` example target
2. Save to `Tests/SwiftONVIFTests/Fixtures/get-capabilities-response-q6325.xml` (and friends)
3. Update the harness to iterate over multiple seeds
4. Re-run the loop — vendor-shape variation will surface bugs the synthetic seed missed
