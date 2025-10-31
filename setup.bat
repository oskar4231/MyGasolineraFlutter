@echo off
echo ========================================
echo   Configuracion del Backend MyGasolinera
echo ========================================
echo.

REM Verificar que Java este instalado
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java no esta instalado o no esta en el PATH
    echo Por favor instala Java JDK 11 o superior
    echo Descarga: https://www.oracle.com/java/technologies/downloads/
    pause
    exit /b 1
)

echo [OK] Java detectado:
java -version
echo.

REM Verificar que las librerias existan
if not exist "basededatosjava\mariadb-java-client-3.5.6.jar" (
    echo [ERROR] No se encuentra mariadb-java-client-3.5.6.jar
    pause
    exit /b 1
)

if not exist "basededatosjava\json-20250517.jar" (
    echo [ERROR] No se encuentra json-20250517.jar
    pause
    exit /b 1
)

echo [OK] Librerias encontradas:
echo   - mariadb-java-client-3.5.6.jar
echo   - json-20250517.jar
echo.

REM Compilar el proyecto
echo Compilando BBDD.java...
cd basededatosjava
javac -cp ".;mariadb-java-client-3.5.6.jar;json-20250517.jar" BBDD.java

if %errorlevel% neq 0 (
    echo [ERROR] Error al compilar
    cd ..
    pause
    exit /b 1
)

cd ..
echo [OK] Compilacion exitosa
echo.
echo ========================================
echo   Configuracion completada!
echo ========================================
echo.
echo Para iniciar el servidor ejecuta: start-server.bat
echo.
pause

