@echo off
curl.exe -s -o NUL -w "SWAGGER_HTTP=%%{http_code}" http://localhost:5087/swagger/index.html > c:\finora_twin\backend\v2_out.txt 2>&1
curl.exe -s -w "\nREGISTER_HTTP=%%{http_code}\n" -X POST -H "Content-Type: application/json" -d "{\"email\":\"e2e_%RANDOM%@verify.local\",\"password\":\"Test1234!\",\"fullName\":\"E2E Verify\"}" http://localhost:5087/api/auth/register >> c:\finora_twin\backend\v2_out.txt 2>&1
exit /b 0
