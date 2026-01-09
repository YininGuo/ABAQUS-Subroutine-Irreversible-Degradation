# Common pitfalls & debugging checklist (USDFLD Tmax / irreversible degradation)

This file is written for the typical workflow:
- USDFLD tracks peak temperature `Tmax` at **integration points**
- You drive material tables using `FIELD(1)=Tmax` + `DEPENDENCIES=1`
- You validate behaviour by plotting `NT` (current temperature) vs `SDV1/FV1` (Tmax)

---

## 1) “Why NT and SDV don't match?” → Node vs integration point

**Most confusion comes from this:**
- `USDFLD` reads **integration-point temperature** via `GETVRM('TEMP', ...)`
- `NT` shown in Abaqus/Viewer is often a **nodal field** (extrapolated + averaged)

So you may see small mismatch even during heating, and bigger mismatch during cooling.

✅ Fix / best practice:
- Extract **integration point** XY data (preferred), or
- Turn off **nodal averaging** in Visualization, then recreate XY plots.

---

## 2) Forgot `*DEPVAR` (STATEV not allocated)

Symptom:
- `SDV1` stays 0 or garbage
- `FIELD(1)` may not behave

✅ Fix:
Add to each material that uses the subroutine:

```
*Depvar
1,
```

---

## 3) `FIELD(1)` not actually driving the material (missing `DEPENDENCIES=1`)

Symptom:
- `SDV1/FV1` looks correct, but stiffness/strength does not degrade with Tmax

✅ Fix:
Make the material property depend on `FIELD(1)`:

```
*Elastic, dependencies=1
E, nu, FIELD1
...
```

---

## 4) Temperature exceeds last table point → unintended extrapolation

Symptom:
- Weird material response at high T
- Convergence issues or unphysical stiffness

✅ Fix:
- Cap `Tmax` in the subroutine (this repo caps at 1200°C by default)
- Ensure your tables include a last point (e.g., 1200°C) representing “fully degraded”

---

## 5) Multi-step analyses: SDV “resets” or jumps

Symptom:
- Entering a new step, `SDV1` returns near 0 or changes unexpectedly

Likely causes:
- Material/section redefined
- Restart/import resets state variables
- Missing robust initialization

✅ Fix:
- Keep material definitions consistent across steps
- Use robust initialization: if `STATEV(1)≈0` then set to current temperature

---

## 6) Visualisation trickiness: averaging & extrapolation

If your plot looks “wrong”:
- Disable nodal averaging in Viewer (Result Options / Computation; wording differs by version)
- Recreate XY data after changing averaging settings
- Prefer integration-point extraction for SDV/FV/PEEQ/S

---

## 7) Amplitude scaling for temperature is not additive

In many cases, Abaqus treats amplitude as a **multiplier** for the base value.

✅ Safe pattern when you want amplitude to directly be absolute temperature:
- Set base temperature value to `1.0`
- Put absolute temperatures in the amplitude table

See `examples/minimal_demo/demo.inp` for this pattern.

---

## 8) What “correct behaviour” looks like

If you plot at the same location (integration point):
- Heating: `SDV1` tracks current temperature closely
- Cooling: `SDV1` stays constant (plateau) at the peak
- Always: `SDV1 >= current temperature` during cooling
