@echo off
setlocal
echo === adb devices ===
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" devices
echo === host curl 5087 ===
curl.exe -s -o NUL -w "HTTP=%%{http_code} TIME=%%{time_total}" http://localhost:5087/swagger/index.html
echo.
echo === emulator curl 10.0.2.2:5087 ===
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" shell "curl -s -o /dev/null -w 'HTTP=%%{http_code}' http://10.0.2.2:5087/swagger/index.html || echo NOCURL"
echo.
echo === DONE ===