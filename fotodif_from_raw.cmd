@echo off
setlocal
set "SIRIL=%ProgramFiles%\Siril\bin\siril-cli.exe"
if not exist "%SIRIL%" set "SIRIL=siril-cli"
"%SIRIL%" -s "%~dp0fotodif_from_raw.ssf"
if errorlevel 1 exit /b %errorlevel%
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0fotodif_copy_timestamps.ps1"
exit /b %errorlevel%
