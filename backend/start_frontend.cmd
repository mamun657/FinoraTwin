@echo off
REM ============================================================
REM Start the FinoraTwin Flutter app (UI only).
REM Usage:  start_frontend.cmd
REM Prereq:  backend must already be running (start_backend.cmd).
REM ============================================================
setlocal
cd /d "c:\finora_twin"
echo.
echo [FinoraTwin] Starting Flutter app on attached Android device...
echo            (default API base: http://127.0.0.1:5087)
echo.
set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not exist "%ADB%" (
	echo [error] adb.exe was not found at %ADB%.
	exit /b 1
)
"%ADB%" reverse tcp:5087 tcp:5087
if errorlevel 1 (
	echo [error] Could not create the ADB reverse tunnel. Check USB debugging and device authorization.
	exit /b 1
)
echo [ok] ADB reverse tunnel: device 127.0.0.1:5087 -^> Windows 127.0.0.1:5087
echo.
flutter run
endlocal
