# Verification guide (does Tmax plateau during cooling?)

Goal: prove your “no recovery / irreversible degradation” logic is working.

## What you should see

At a given integration point:

- During heating: `SDV1` (or `FV1`) rises with temperature.
- At peak: `SDV1 ≈ TEMP`
- During cooling: **current temperature decreases**, but `SDV1/FV1` stays constant at the peak.

In other words, during cooling: `SDV1 ≥ current temperature` and forms a plateau.

---

## Minimal demo

1. Go to `examples/minimal_demo/`
2. Run `run.bat` (Windows) or run:

```
abaqus job=demo input=demo.inp user=..\..\src\usdfld_tmax_irrev.for interactive
```

3. Open `demo.odb`

---

## Extract the right thing (important)

USDFLD reads temperature at the **integration point**.

If you plot nodal `NT` with averaging, it may not match perfectly.

### Recommended approach
- Create XY data from **integration point** quantities:
  - `SDV1` (state variable) or `FV1` (field variable)
  - temperature at integration points (if available in your extraction workflow)

### Practical check that still works
Even if you only have nodal `NT`:
- `SDV1` should not decrease during cooling
- `SDV1` should reach around the peak temperature you imposed

---

## Output requests you need

Make sure Field Output includes:
- `SDV` (state variables)
- `FV` (field variables)
- `NT` (temperature)

In `.inp`, for example:

```
*Output, field, frequency=...
*Node Output
NT
*Element Output
SDV, FV
```

---

## Common “false alarms”

### “My SDV1 is slightly lower/higher than NT”
Usually node vs integration point effects (extrapolation + averaging). See `docs/pitfalls.md`.

### “SDV1 starts at 0 for a short while”
If your initial increment doesn’t update as expected, check:
- `*DEPVAR` exists
- `USDFLD` is being compiled/linked and actually used by the job
- Your initialization rule (this repo uses: if STATEV(1)≈0 then set to current TEMP)

---

## What to report in a paper (one sentence)

“A peak-temperature field variable was tracked at each integration point using USDFLD, and mechanical properties were defined as functions of the peak temperature to enforce irreversible timber degradation during the cooling phase.”
