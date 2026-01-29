@echo off
echo ========================================
echo   Flutter Build + Servidor Simple
echo ========================================
echo.
echo 1. Compilando app web...
echo.

flutter build web --release

echo.
echo 2. Iniciando servidor en http://localhost:8080
echo.
echo Abre tu navegador en: http://localhost:8080
echo.

cd build\web
python -m http.server 8080

pause
