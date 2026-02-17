# 🚗 Documentación de Logos de Marcas

Esta funcionalidad permite mostrar el logo de la marca del coche en la tarjeta de información, reemplazando el icono genérico.

## 📂 Ubicación de Archivos

- **Directorio de imágenes:** `assets/images/logos/`
- **Widget encargado:** `lib/Implementaciones/coches/presentacion/widgets/brand_logo.dart`

## ⚙️ Funcionamiento Técnico

El widget `BrandLogo` toma el nombre de la marca (ej: "Mercedes-Benz") y lo normaliza para encontrar el archivo de imagen correspondiente.

**Lógica de Normalización:**
1. Conversión a minúsculas (`toLowerCase()`).
2. Eliminación de espacios en blanco al inicio/final (`trim()`).
3. Reemplazo de espacios (` `) por guiones (`-`).
4. Reemplazo de barras (`/`) por guiones (`-`).

**Ejemplos:**
- "Mercedes-Benz" -> `mercedes-benz.png`
- "Opel/Vauxhall" -> `opel-vauxhall.png`
- "Land Rover" -> `land-rover.png`

Si la imagen no existe, se muestra un icono por defecto (`Icons.directions_car`).

## 📋 Lista de Marcas Soportadas (Actual)

| Marca | Archivo Requerido |
| :--- | :--- |
| **Alfa Romeo** | `alfa-romeo.png` |
| **Audi** | `audi.png` |
| **BMW** | `bmw.png` |
| **Citroen** | `citroen.png` |
| **Cupra** | `cupra.png` |
| **Dacia** | `dacia.png` |
| **DS** | `ds.png` |
| **Fiat** | `fiat.png` |
| **Ford** | `ford.png` |
| **Honda** | `honda.png` |
| **Hyundai** | `hyundai.png` |
| **Jeep** | `jeep.png` |
| **Kia** | `kia.png` |
| **Land Rover** | `land-rover.png` |
| **Mazda** | `mazda.png` |
| **Mercedes-Benz** | `mercedes-benz.png` |
| **MG** | `mg.png` |
| **Mini** | `mini.png` |
| **Nissan** | `nissan.png` |
| **Opel/Vauxhall** | `opel-vauxhall.png` |
| **Peugeot** | `peugeot.png` |
| **Porsche** | `porsche.png` |
| **Renault** | `renault.png` |
| **Seat** | `seat.png` |
| **Skoda** | `skoda.png` |
| **Suzuki** | `suzuki.png` |
| **Tesla** | `tesla.png` |
| **Toyota** | `toyota.png` |
| **Volkswagen** | `volkswagen.png` |
| **Volvo** | `volvo.png` |

## ➕ Cómo añadir una nueva marca

1.  Consigue el logo en formato **PNG** (preferiblemente con fondo transparente).
2.  Renómbralo siguiendo la lógica de normalización (todo minúsculas, espacios como guiones).
3.  Guárdalo en `assets/images/logos/`.
4.  Reinicia la aplicación (`flutter run`) para que se reconozca el nuevo asset.
