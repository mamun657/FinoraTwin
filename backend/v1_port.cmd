@echo off
netstat -ano | findstr :5087 > c:\finora_twin\backend\v1_out.txt 2>&1
exit /b 0
