@echo off
setlocal enabledelayedexpansion

echo DEBUG input: %1

REM === Require input argument ===
if "%~1"=="" (
    echo ***************************************************
    echo This script is part of the TGDAP Project
    echo At this stage, it is intended solely to assist
	echo in calculating drift from the Scintrex CG-5 over 
	echo time within a loop survey.
	echo(
    echo Usage: [%~nx0] [inputfile.txt]
	echo Example: %~nx0 ..\raw_data\filename.txt
    echo(
	echo Terrestrial Gravity Data Assessment Project
	echo Version 1.0 WP 02/12/2025 - Calculating drift [CG5]
	echo ***************************************************
    exit /b 1
)

REM === Script directory ===
set "SRC_DIR=%~dp0"

REM === AWK script check ===
if not exist "%SRC_DIR%driftcal.awk" (
    echo ERROR: driftcal.awk NOT FOUND in %SRC_DIR%
    exit /b 1
)

REM === Convert input file to absolute path ===
set "infile=%~1"
for %%A in ("%infile%") do set "infile=%%~fA"

REM === Verify input file exists ===
if not exist "%infile%" (
    echo ERROR: Input file NOT FOUND: %infile%
    exit /b 1
)

REM === Prepare results folder ===
set "OUTDIR=%SRC_DIR%..\results"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM === Run AWK ===
set "outfile=%OUTDIR%\%~n1_drift.txt"

echo ---------------------------------------------------------------
echo Running drift calculation...
gawk -f "%SRC_DIR%driftcal.awk" "%infile%" > "%outfile%"

echo Drift calculation completed!
echo Output saved at:
echo %outfile%
echo ---------------------------------------------------------------
