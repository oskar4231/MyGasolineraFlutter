@echo off
echo ========================================
echo   Compilando Backend MyGasolinera
echo ========================================
echo.

cd basededatosjava
javac -cp ".;mariadb-java-client-3.5.6.jar;json-20250517.jar" BBDD.java

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   Compilacion exitosa!
    echo ========================================
    echo.
    echo Ahora puedes ejecutar: start-server.bat
) else (
    echo.
    echo ========================================
    echo   Error en la compilacion
    echo ========================================
)

echo.
pause

