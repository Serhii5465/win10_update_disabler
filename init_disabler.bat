@echo off

net session >nul 2>&1
if %errorLevel% == 0 (
    "%~dp0PsExec.exe" -i \\%COMPUTERNAME% -s powershell -executionpolicy unrestricted -file "%~dp0Win10_Update_Disabler.ps1"
) else (
    echo Access denied
)

pause