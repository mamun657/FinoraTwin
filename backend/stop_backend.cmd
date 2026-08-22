@echo off
REM ============================================================
REM Stop the FinoraTwin.Api backend.
REM Usage:  stop_backend.cmd
REM ============================================================
setlocal
set "PORT=5087"

echo.
echo [FinoraTwin] Stopping backend on port %PORT%...
set "KILLED=0"
for /f "tokens=5" %%P in ('netstat -ano 2^>nul ^| findstr LISTENING ^| findstr ":%PORT% "') do (
    echo   killing PID %%P
    taskkill /F /PID %%P >nul 2>&1
    set "KILLED=1"
)
if "%KILLED%"=="0" echo   nothing was listening on port %PORT%.
echo.
endlocal
