# Documentación Técnica del Módulo de Mapa 🗺️

**Fecha:** 17 de Febrero, 2026
**Módulo:** Mapa (Flutter) + Backend (Node.js/MariaDB)
**Responsable:** Equipo de Desarrollo (Antigravity)

---

Este documento detalla las soluciones técnicas implementadas para resolver problemas de rendimiento, usabilidad y consistencia de datos en el módulo de visualización de gasolineras.

## 1. Optimización de Red (Frontend) 🚀

### El Problema
Al mover el mapa rápidamente (scroll) o hacer zoom, el evento `onCameraIdle` se disparaba demasiadas veces consecutivas. Esto provocaba un "bombardeo" de peticiones HTTP al backend, saturando la red y ralentizando la UI.

### La Solución: Debounce
Implementamos un **temporizador de cancelación (Debounce)** de 500ms en el controlador del mapa.

**Cómo funciona:**
Cada vez que la cámara se detiene (`onCameraIdle`), cancelamos cualquier temporizador pendiente y arrancamos uno nuevo. La petición al servidor solo se lanza si la cámara permanece quieta durante 500ms.

```dart
// map_widget.dart
_cameraDebounceTimer?.cancel();
_cameraDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
  // Solo ejecuta la carga si el usuario dejó de mover el mapa por 500ms
  await _cargarGasolinerasPorBounds(...);
});
```

---

## 2. Renderizado de Iconos y Precarga 🖼️

### El Problema
Los marcadores del mapa parpadeaban ("flickering") o aparecían con el estilo por defecto de Google (globo rojo) durante unos milisegundos al cargar o redibujar el mapa, degradando la experiencia de usuario.

### La Solución: Precarga de BitmapDescriptor
Movemos la lógica de decodificación y transformación de imágenes al inicio del ciclo de vida del widget.

**Implementación:**
- En el `initState`, antes de solicitar la ubicación o mostrar el mapa, llamamos a `_markerHelper.loadGasStationIcons()`.
- Esto carga, redimensiona y almacena los `BitmapDescriptor` en memoria (`_gasStationIcon` y `_favoriteGasStationIcon`).
- Cuando el mapa necesita pintar un marcador, el icono ya está listo en RAM, eliminando el parpadeo.

---

## 3. Lógica de "Decluttering" vs Clustering 📍

### El Problema
El sistema de "Clustering" tradicional agrupaba gasolineras en círculos de colores con números (ej: un círculo azul con un "10"). Esto rompía la estética de la marca y ocultaba información relevante (como si había una gasolinera favorita en el grupo).

### La Solución: Decluttering Personalizado
"Engañamos" al `ClusterManager` para que se comporte como un sistema de limpieza visual (Decluttering) en lugar de agrupación numérica.

**Reglas de Negocio en `_markerBuilder`:**
1.  **Icono Único:** Independientemente de si es un grupo (`isMultiple == true`) o una gasolinera sola, **SIEMPRE** usamos nuestros iconos personalizados (`iconoFinal.png` o `iconoFavFinal.png`). Nunca mostramos círculos ni números.
2.  **Prioridad de Favoritos:** Si un grupo contiene 50 gasolineras y **una** de ellas es favorita, el icono del grupo entero se convierte en la estrella de favorita. Esto asegura que el usuario nunca pierda de vista sus preferencias.
3.  **Interacción (Zoom Suave):** Al tocar un grupo, en lugar de no hacer nada o expandir bruscamente, usamos `animateCamera` para un acercamiento fluido que revela el contenido.

```dart
// map_widget.dart
onTap: () {
  // Acercamiento elegante para "abrir" el grupo
  mapController!.animateCamera(
    CameraUpdate.newLatLngZoom(cluster.location, _currentZoom + 2.0),
  );
}
```

---

## 4. Ajuste de Hitboxes y Anchor 🎯

### El Problema
Los usuarios reportaban que al tocar un marcador, a veces no respondía o se activaba el de al lado. Esto ocurría porque las imágenes PNG tenían márgenes transparentes grandes, y Google Maps centra la imagen por defecto `Offset(0.5, 0.5)`.

### La Solución: Trimming y Anchor Base
1.  **Edición Gráfica:** Se recortaron los márgenes transparentes de las imágenes (usando herramientas como GIMP/Photoshop) para que el tamaño de la imagen sea estrictamente el contenido visible.
2.  **Anchor Correcto:** Configuramos el `anchor` del marcador en `Offset(0.5, 1.0)`.
    - `0.5` (X): Centro horizontal.
    - `1.0` (Y): Base inferior.
    - **Resultado:** El punto "caliente" del click es exactamente la punta inferior de la gota de la gasolinera, garantizando precisión milimétrica.

---

## 5. Consultas Espaciales (Backend Node.js + MariaDB) 🌍

### El Problema Crítico
Las consultas espaciales fallaban o devolvían resultados erróneos. El problema raíz era el orden de las coordenadas al construir los polígonos WKT (Well-Known Text).

### La Solución: Estándar (Longitud Latitud)
MariaDB (y la mayoría de sistemas GIS siguiendo el estándar OGC) espera las coordenadas en el orden **(X Y)**, es decir, **(Longitud Latitud)**. Google Maps nos da (Latitud, Longitud).

**Corrección implementada:**
Al construir el polígono para `ST_GeomFromText` y `MBRContains`:
1.  Invertimos el orden: Primero Longitud, luego Latitud.
2.  Cerramos el polígono: El primer y último punto deben ser idénticos.

**Formato SQL Correcto:**
```sql
-- POLYGON((Lng1 Lat1, Lng2 Lat2, Lng3 Lat3, Lng4 Lat4, Lng1 Lat1))
SELECT * FROM gasolineras 
WHERE MBRContains(
  ST_GeomFromText('POLYGON((-0.37 39.46, -0.35 39.46, -0.35 39.48, -0.37 39.48, -0.37 39.46))'), 
  ubicacion
);
```

Esta corrección aseguró que el backend filtre correctamente las gasolineras dentro del área visible del mapa móvil.
