@echo off
setlocal
set "PORT=5087"
set "PROJ=c:\finora_twin\backend\FinoraTwin.Api"
set "LOG=c:\finora_twin\backend\backend_now.log"

REM Cleanup any stale owner
for /f "tokens=5" %%P in ('netstat -ano 2^>nul ^| findstr LISTENING ^| findstr ":%PORT% "') do (
    echo   [cleanup] killing stale PID %%P on port %PORT%
    taskkill /F /PID %%P >nul 2>&1
)
timeout /t 2 /nobreak >nul

REM Bind to all interfaces (0.0.0.0) so physical device can reach it via LAN IP
echo   [start] launching FinoraTwin.Api on 0.0.0.0:%PORT%...
start "FinoraBackend" /MIN cmd /c "cd /d %PROJ% && dotnet run --no-launch-profile --urls http://0.0.0.0:%PORT% >> %LOG% 2>&1"

REM Wait for TCP listener
set "READY=0"
for /l %%I in (1,1,60) do (
    timeout /t 1 /nobreak >nul
    powershell -NoProfile -Command "Test-NetConnection -ComputerName 127.0.0.1 -Port %PORT% -WarningAction SilentlyContinue -InformationLevel Quiet" >nul 2>&1
    if not errorlevel 1 (
        set "READY=1"
        goto :ready
    )
)
goto :notready

:ready
echo   [ok] TCP listener is UP on 0.0.0.0:%PORT%.
echo   URL: http://0.0.0.0:%PORT%
endlocal & exit /b 0

:notready
echo   [error] backend did not start in 60s. Check %LOG%.
endlocal & exit /b 2