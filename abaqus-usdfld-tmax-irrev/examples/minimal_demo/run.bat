@echo off
REM ============================================================
REM Minimal run script (Windows) for the demo.
REM Edit ABAQUS_CMD if your Abaqus command name differs.
REM ============================================================
set ABAQUS_CMD=abaqus

REM Run from this folder (examples\minimal_demo)
%ABAQUS_CMD% job=demo input=demo.inp user=..\..\src\usdfld_tmax_irrev.for interactive
pause
