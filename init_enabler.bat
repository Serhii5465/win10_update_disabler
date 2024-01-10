NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo Success: Administrative permissions confirmed.
    "%~dp0PsExec.exe" -i -s powershell -executionpolicy unrestricted -noexit -File "%~dp0Win10_Update_Enabler.ps1"
) ELSE (
    echo Failure: Current permissions inadequate.
)

pause