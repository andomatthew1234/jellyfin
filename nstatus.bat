@echo off
REM nstatus.bat
REM Bypasses execution policies dynamically just for this run so your beautiful UI always works.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0nstatus.ps1"