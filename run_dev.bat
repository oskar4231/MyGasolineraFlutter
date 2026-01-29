@echo off
echo ========================================
echo   Ejecutando Flutter Web (Sin CORS)
echo ========================================
echo.
echo Metodo 1: Intentando con flutter run...
echo.

REM Intentar primero con flutter run
flutter run -d chrome

echo.
echo Si ves errores CORS, cierra Chrome y ejecuta run_dev_chrome.bat
pause
