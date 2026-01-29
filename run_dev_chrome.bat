@echo off
echo ========================================
echo   Chrome SIN CORS - Solo Desarrollo
echo ========================================
echo.
echo ADVERTENCIA: Este Chrome NO es seguro
echo Solo usar para desarrollo de Flutter
echo.

REM Cerrar todas las instancias de Chrome primero
taskkill /F /IM chrome.exe 2>nul
timeout /t 2 /nobreak >nul

REM Ejecutar Chrome con CORS deshabilitado
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --disable-web-security --disable-gpu --user-data-dir=%TEMP%\chrome_dev_cors --new-window http://localhost:8080

echo.
echo Chrome iniciado sin CORS
echo Ahora ejecuta: flutter run -d web-server --web-port=8080
echo.
pause
