# 📦 Paquetes y Dependencias del Proyecto

## 🎯 Dependencias de Producción

### Core Flutter
- **flutter**: Framework principal de Flutter
  SDK oficial para desarrollo multiplataforma

- **flutter_localizations**: Soporte de internacionalización
  Traducciones y formatos locales

### 📸 Imágenes y Multimedia
- **image_picker**: Seleccionar imágenes de galería/cámara
  Captura fotos o elige archivos

- **cached_network_image**: Caché de imágenes de red
  Optimiza carga y almacena imágenes

- **google_mlkit_text_recognition**: Reconocimiento óptico de caracteres (OCR)
  Extrae texto de imágenes

### 🗺️ Mapas y Geolocalización
- **google_maps_flutter**: Integración de Google Maps
  Muestra mapas interactivos en app

- **geolocator**: Obtener ubicación GPS del dispositivo
  Coordenadas y seguimiento de posición

- **geocoding**: Conversión coordenadas ↔ direcciones
  Traduce lat/lng a direcciones legibles

### 🔐 Permisos
- **permission_handler**: Gestión de permisos del sistema
  Solicita acceso a cámara, ubicación, etc.

### 🌐 Red y Comunicación
- **http**: Cliente HTTP para peticiones REST
  Comunicación con APIs y backend

- **url_launcher**: Abrir URLs externas y aplicaciones
  Lanza navegador, email, teléfono, etc.

### 💾 Almacenamiento y Base de Datos
- **drift**: ORM y base de datos SQL local
  Gestión de datos offline con SQLite

- **drift_flutter**: Integración Drift con Flutter
  Soporte específico para plataformas móviles

- **sqlite3_flutter_libs**: Librerías nativas SQLite
  Binarios SQLite para cada plataforma

- **shared_preferences**: Almacenamiento clave-valor simple
  Guarda preferencias y configuraciones pequeñas

- **path_provider**: Rutas de directorios del sistema
  Acceso a carpetas de documentos/caché

- **path**: Manipulación de rutas de archivos
  Operaciones con paths multiplataforma

### 📄 Documentos y Archivos
- **excel**: Crear y leer archivos Excel
  Genera hojas de cálculo .xlsx

- **pdf**: Generación de documentos PDF
  Crea PDFs programáticamente

- **printing**: Imprimir y compartir PDFs
  Envía documentos a impresora física

- **file_picker**: Selector de archivos del sistema
  Permite elegir cualquier tipo archivo

- **share_plus**: Compartir contenido con otras apps
  Integración con menú de compartir nativo

### 🎨 UI y Utilidades
- **cupertino_icons**: Iconos estilo iOS
  Set de iconos de Cupertino

- **intl**: Internacionalización y formateo
  Fechas, números y monedas localizadas

- **package_info_plus**: Información de la app
  Versión, nombre y metadatos del paquete

### 🌍 Web
- **universal_html**: API HTML multiplataforma
  Compatibilidad web/móvil para HTML

- **web**: Interoperabilidad con APIs web
  Acceso a funciones del navegador

---

## 🛠️ Dependencias de Desarrollo

### Testing
- **flutter_test**: Framework de testing de Flutter
  Pruebas unitarias y de widgets

- **mocktail**: Mocking para tests
  Crea objetos simulados para testing

### Calidad de Código
- **flutter_lints**: Reglas de análisis estático
  Estándares de código recomendados

### Generación de Código
- **build_runner**: Ejecutor de generadores de código
  Compila anotaciones y genera archivos

- **drift_dev**: Generador de código para Drift
  Crea clases DAO desde esquemas

### Recursos
- **flutter_launcher_icons**: Generador de iconos de app
  Crea iconos adaptativos automáticamente

---

## 📊 Resumen por Categoría

| Categoría | Cantidad |
|-----------|----------|
| Imágenes y Multimedia | 3 |
| Mapas y Geolocalización | 3 |
| Almacenamiento | 5 |
| Documentos | 5 |
| Red y Comunicación | 2 |
| UI y Utilidades | 3 |
| Web | 2 |
| Testing | 2 |
| Herramientas de Desarrollo | 3 |
| **TOTAL** | **28** |
