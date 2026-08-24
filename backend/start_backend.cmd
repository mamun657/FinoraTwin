@echo off
setlocal
set "PORT=5087"
set "PROJ=c:\finora_twin\backend\FinoraTwin.Api"
set "LOG=c:\finora_twin\backend\backend_now.log"
set "PROBE=c:\finora_twin\backend\backend_probe.log"

REM ---- 1. Cleanup any stale owner of the port (FinoraTwin only) ----
set "DROPPED=0"
for /f "tokens=5" %%P in ('netstat -ano 2^>nul ^| findstr LISTENING ^| findstr ":%PORT% "') do (
    REM Resolve what owns the PID
    set "PIDSUMMARY="
    for /f "tokens=1" %%N in ('tasklist /FI "PID eq %%P" 2^>nul ^| findstr /B "INFO:"') do set "PIDSUMMARY=%%N"
    set "PIDSUMMARY=!PIDSUMMARY!"
    REM Only kill if it's FinoraTwin.Api.exe (dotnet host) or our own session
    set "CMDLINE="
    for /f "tokens=*" %%C in ('wmic process where "ProcessId=%%P" get CommandLine /value 2^>nul') do (
        if "%%C" NEQ "" set "CMDLINE=!CMDLINE! %%C"
    )
    echo !CMDLINE! | findstr /I "FinoraTwin.Api" >nul 2>&1
    if not errorlevel 1 (
        echo   [cleanup] killing stale FinoraTwin backend PID %%P
        taskkill /F /PID %%P >nul 2>&1
        set "DROPPED=1"
    ) else (
        echo   [cleanup] PID %%P on port %PORT% is NOT a FinoraTwin process -- leaving untouched
    )
)
if "%DROPPED%"=="1" (
    timeout /t 2 /nobreak >nul
)

REM ---- 2. Verify port is free ----
netstat -ano | findstr LISTENING | findstr ":%PORT% " >nul
if not errorlevel 1 (
    echo   [error] port %PORT% is still busy. Aborting.
    exit /b 1
)

REM ---- 3. Launch backend in a fully detached console ----
echo   [start] launching FinoraTwin.Api on port %PORT%...
echo   [start] logs: %LOG%
start "FinoraBackend" /MIN cmd /c "cd /d %PROJ% && dotnet run --launch-profile http >> %LOG% 2>&1"

REM ---- 4. Wait using an HTTP probe (not a log grep) ----
set "READY=0"
for /l %%I in (1,1,60) do (
    timeout /t 1 /nobreak >nul
    curl.exe -s --connect-timeout 1 -o NUL http://127.0.0.1:%PORT%/swagger/index.html >nul 2>&1
    if errorlevel 1 (
        rem Keep waiting while the API is starting.
    ) else (
        set "READY=1"
        goto :ready
    )
)
goto :notready

:ready
echo   [ok] HTTP endpoint on 127.0.0.1:%PORT% is UP.
echo   [verify] HTTP probe
curl.exe -s -o NUL -w "   swagger_http=%%{http_code}\n" http://localhost:%PORT%/swagger/index.html
echo.
echo [FinoraTwin] Backend is UP.  URL: http://localhost:%PORT%
echo   Logs: %LOG%
echo   Stop:  c:\finora_twin\backend\stop_backend.cmd
echo.
endlocal & exit /b 0

:notready
echo.
echo [FinoraTwin] Backend did NOT start in 60s.  Check: %LOG%
endlocal & exit /b 2
