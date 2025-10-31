@echo off
echo ========================================
echo   Verificacion del Entorno
echo ========================================
echo.

REM Verificar Java
echo [1/4] Verificando Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Java NO encontrado
    echo     Instala Java JDK 11 o superior
) else (
    echo [OK] Java encontrado
    java -version 2>&1 | findstr "version"
)
echo.

REM Verificar javac
echo [2/4] Verificando compilador Java...
javac -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] javac NO encontrado
    echo     Necesitas el JDK completo, no solo el JRE
) else (
    echo [OK] javac encontrado
    javac -version
)
echo.

REM Verificar librerias
echo [3/4] Verificando librerias...
if exist "basededatosjava\mariadb-java-client-3.5.6.jar" (
    echo [OK] mariadb-java-client-3.5.6.jar
) else (
    echo [X] mariadb-java-client-3.5.6.jar NO encontrado
)

if exist "basededatosjava\json-20250517.jar" (
    echo [OK] json-20250517.jar
) else (
    echo [X] json-20250517.jar NO encontrado
)
echo.

REM Verificar archivos de configuracion
echo [4/4] Verificando configuracion del IDE...
if exist ".vscode\settings.json" (
    echo [OK] .vscode\settings.json
) else (
    echo [!] .vscode\settings.json NO encontrado
)

if exist ".classpath" (
    echo [OK] .classpath
) else (
    echo [!] .classpath NO encontrado
)

if exist ".project" (
    echo [OK] .project
) else (
    echo [!] .project NO encontrado
)
echo.

echo ========================================
echo   Verificacion completada
echo ========================================
echo.
echo Si todo esta [OK], ejecuta: setup.bat
echo.
pause

