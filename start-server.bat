@echo off
echo ========================================
echo   MyGasolinera Backend Server
echo ========================================
echo.
echo Iniciando servidor en http://localhost:5001
echo.
echo Endpoints disponibles:
echo   - POST /register (Crear cuenta)
echo   - POST /login    (Iniciar sesion)
echo.
echo Presiona Ctrl+C para detener el servidor
echo ========================================
echo.

cd basededatosjava
java -cp ".;mariadb-java-client-3.5.6.jar;json-20250517.jar" BBDD

pause

