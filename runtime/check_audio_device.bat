@echo off
setlocal

set "PY=%~dp0python312\python.exe"
set "SCRIPT=%~dp0sd.py"
set "EXE=%~dp0DVCRuntime.exe"

if exist "%PY%" (
  "%PY%" "%SCRIPT%"
  goto :end
)

if exist "%EXE%" (
  "%EXE%" --check-audio-device
  goto :end
)

echo ERROR: python312\python.exe or DVCRuntime.exe not found.

:end
pause