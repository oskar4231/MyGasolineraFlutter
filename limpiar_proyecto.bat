@echo off
echo ==========================================
echo       LIMPIANDO ARCHIVOS TEMPORALES
echo ==========================================
echo.
echo Ejecutando flutter clean...
call flutter clean
echo.
echo Eliminando directorio build si existe...
if exist "build" rmdir /s /q "build"
echo.
echo Eliminando directorio .dart_tool si existe...
if exist ".dart_tool" rmdir /s /q ".dart_tool"
echo.
echo Eliminando cache de Android (.gradle)...
if exist "android\.gradle" rmdir /s /q "android\.gradle"
echo.
echo ==========================================
echo        LIMPIEZA COMPLETADA
echo ==========================================
echo.
pause
