#!/bin/bash

echo "========================================"
echo "  Configuracion del Backend MyGasolinera"
echo "========================================"
echo ""

# Verificar que Java este instalado
if ! command -v java &> /dev/null; then
    echo "[ERROR] Java no esta instalado o no esta en el PATH"
    echo "Por favor instala Java JDK 11 o superior"
    echo "Ubuntu/Debian: sudo apt install default-jdk"
    echo "macOS: brew install openjdk@11"
    exit 1
fi

echo "[OK] Java detectado:"
java -version
echo ""

# Verificar que las librerias existan
if [ ! -f "basededatosjava/mariadb-java-client-3.5.6.jar" ]; then
    echo "[ERROR] No se encuentra mariadb-java-client-3.5.6.jar"
    exit 1
fi

if [ ! -f "basededatosjava/json-20250517.jar" ]; then
    echo "[ERROR] No se encuentra json-20250517.jar"
    exit 1
fi

echo "[OK] Librerias encontradas:"
echo "  - mariadb-java-client-3.5.6.jar"
echo "  - json-20250517.jar"
echo ""

# Compilar el proyecto
echo "Compilando BBDD.java..."
cd basededatosjava
javac -cp ".:mariadb-java-client-3.5.6.jar:json-20250517.jar" BBDD.java

if [ $? -ne 0 ]; then
    echo "[ERROR] Error al compilar"
    cd ..
    exit 1
fi

cd ..
echo "[OK] Compilacion exitosa"
echo ""
echo "========================================"
echo "  Configuracion completada!"
echo "========================================"
echo ""
echo "Para iniciar el servidor ejecuta:"
echo "  cd basededatosjava"
echo "  java -cp \".:mariadb-java-client-3.5.6.jar:json-20250517.jar\" BBDD"
echo ""

