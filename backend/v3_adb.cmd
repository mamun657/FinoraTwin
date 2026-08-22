@echo off
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" devices > c:\finora_twin\backend\v3_out.txt 2>&1
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" shell getprop ro.product.model >> c:\finora_twin\backend\v3_out.txt 2>&1
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" shell wm size >> c:\finora_twin\backend\v3_out.txt 2>&1
exit /b 0
