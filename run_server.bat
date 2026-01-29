@echo off
echo ========================================
echo   Flutter Web Server (Sin Firewall)
echo ========================================
echo.
echo Iniciando servidor web en http://localhost:8080
echo Abre manualmente en tu navegador favorito
echo.
echo IMPORTANTE: Usa http://localhost:8080 en el navegador
echo.

flutter run -d web-server --web-port=8080

pause
