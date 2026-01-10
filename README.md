# Abaqus Irreversible Material subroutine (AIMs)

This repository provides an Abaqus/Standard `USDFLD` subroutine that tracks the **peak temperature** at each integration point:

- `STATEV(1) = Tmax` (°C)
- `FIELD(1)  = Tmax` (°C)

This enables **irreversible** material degradation during cooling: your material properties can depend on **peak temperature** (`FIELD(1)`), not on the current temperature.

## Repository structure

- `src/usdfld_tmax_irrev.for` — the subroutine
- `examples/minimal_demo/demo.inp` — a tiny verification case (heat up then cool down)
- `docs/pitfalls.md` — common pitfalls (NT vs SDV, averaging, DEPVAR, etc.)
- `docs/verification.md` — how to verify plateau behaviour in ODB
- `.gitignore` — prevents pushing big Abaqus files by accident

## How it works

At every increment and integration point:

1. Read current temperature at the integration point using `GETVRM('TEMP', ...)`
2. Update: `Tmax = max(previous Tmax, current TEMP)`
3. Set `FIELD(1) = Tmax` so material tables with `DEPENDENCIES=1` use peak temperature

During cooling, `TEMP` decreases but `Tmax` stays constant → “no recovery”.

## How to use in your model

### 1) Add state variables to the material
In your material definition:

```
*Depvar
1,
```

### 2) Make properties depend on FIELD(1)
For example, elastic modulus depending on peak temperature (the last column is `FIELD(1)`):

```
*Elastic, dependencies=1
11000., 0.02, 20.
3850.,  0.02, 100.
1.,     0.02, 300.
1.,     0.02, 1200.
```

### 3) Run with the user subroutine
Example command:

```
abaqus job=YOURJOB input=YOURJOB.inp user=src/usdfld_tmax_irrev.for interactive
```

## Quick verification (recommended)

Run the minimal demo:
- Go to `examples/minimal_demo/`
- Double-click `run.bat` (Windows) or run the Abaqus command manually.

Then open the `.odb` and check:
- heating phase: `SDV1` ≈ current temperature
- cooling phase: `SDV1` stays at the peak (plateau) and `SDV1 ≥ NT`

Details are in `docs/verification.md`.
