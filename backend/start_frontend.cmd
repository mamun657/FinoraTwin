@echo off
REM ============================================================
REM Start the FinoraTwin Flutter app (UI only).
REM Usage:  start_frontend.cmd
REM Prereq:  backend must already be running (start_backend.cmd).
REM ============================================================
setlocal
cd /d "c:\finora_twin"
echo.
echo [FinoraTwin] Starting Flutter app on attached emulator...
echo            (default API base: http://10.0.2.2:5087)
echo.
flutter run
endlocal
