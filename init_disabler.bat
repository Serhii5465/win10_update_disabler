@echo off

net session >nul 2>&1
if %errorLevel% == 0 (
    "%~dp0PsExec.exe" -i \\%COMPUTERNAME% -s powershell -executionpolicy unrestricted -file "%~dp0upd_disabler.ps1"
) else (
    echo Access denied
)

pause