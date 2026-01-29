# 🚀 Soluciones para Red de Instituto (Firewall)

## Problema
El firewall del instituto bloquea:
- ❌ Conexiones WebSocket (debug de Flutter)
- ❌ CORS entre localhost y Cloudflare Tunnel

## ✅ Soluciones Disponibles

### Opción 1: Modo Release (Recomendado) ⭐
```bash
run_edge.bat
```

**Ventajas**:
- ✅ No usa WebSocket (evita firewall)
- ✅ Más rápido que modo debug
- ✅ Funciona en cualquier navegador

**Desventajas**:
- ❌ No puedes usar hot reload
- ❌ Tarda más en compilar

---

### Opción 2: Web Server + Navegador Manual
```bash
run_server.bat
```

Luego abre manualmente en tu navegador:
```
http://localhost:8080
```

**Ventajas**:
- ✅ Evita problemas de firewall
- ✅ Puedes elegir cualquier navegador
- ✅ Hot reload funciona (con F5 manual)

---

### Opción 3: Compilar y Servir Estático
```bash
flutter build web --release
cd build\web
python -m http.server 8000
```

Abre: `http://localhost:8000`

---

## 🎯 Recomendación para Instituto

**Para desarrollo rápido**:
```bash
run_server.bat
```
Luego abre `http://localhost:8080` en Edge o Chrome

**Para presentar/demostrar**:
```bash
run_edge.bat
```

---

## 📝 Notas

> [!TIP]
> Si necesitas debug, considera usar la **APK** en lugar de web:
> ```bash
> flutter run -d windows
> ```
> La versión de escritorio no tiene restricciones CORS.

> [!WARNING]
> El modo release tarda más en compilar (2-3 minutos) pero evita todos los problemas de firewall.
