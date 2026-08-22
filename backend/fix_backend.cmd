@echo off
setlocal
echo === Backend port 5087 holders ===
netstat -ano | findstr :5087
echo.
echo === Killing any dotnet holding port 5087 ===
for /f "tokens=5" %%P in ('netstat -ano ^| findstr LISTENING ^| findstr :5087') do (
    echo   killing PID %%P
    taskkill /F /PID %%P >nul 2>&1
)
echo.
echo === After cleanup ===
netstat -ano | findstr :5087
echo.
echo === Starting backend ===
cd /d "c:\finora_twin\backend\FinoraTwin.Api"
start "FinoraBackend" /B cmd /c "dotnet run --launch-profile http > c:\finora_twin\backend\backend_fixed.log 2>&1"
echo   launched, waiting 25s for startup...
timeout /t 25 /nobreak >nul
echo.
echo === Backend log tail ===
if exist c:\finora_twin\backend\backend_fixed.log (
    powershell -NoProfile -Command "Get-Content 'c:\finora_twin\backend\backend_fixed.log' -Tail 15"
)
echo.
echo === Port 5087 now ===
netstat -ano | findstr :5087
echo.
echo === Health probe ===
curl.exe -s -o NUL -w "swagger_http=%%{http_code}\n" http://localhost:5087/swagger/index.html
curl.exe -s -o NUL -w "register_http=%%{http_code}\n" -X POST -H "Content-Type: application/json" -d "{\"email\":\"smoke_%RANDOM%@e.com\",\"password\":\"Test1234!\",\"fullName\":\"Smoke\"}" http://localhost:5087/api/auth/register
echo.
echo === DONE ===
endlocal
