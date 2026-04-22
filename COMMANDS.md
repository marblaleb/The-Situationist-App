# Comandos para correr la aplicación

## Requisitos previos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x instalado
- `openssl` disponible en la terminal (incluido en macOS/Linux; en Windows usar Git Bash o WSL)

---

## 1. Configuración inicial (una sola vez)

### 1.1 Generar par de claves RSA para JWT

```bash
openssl genrsa -out private_key.pem 2048
openssl rsa -in private_key.pem -pubout -out public_key.pem
```

### 1.2 Crear el archivo de variables de entorno

```bash
cp .env.example .env
```

Edita `.env` y rellena los valores:

| Variable | Descripción |
|---|---|
| `POSTGRES_PASSWORD` | Contraseña para la base de datos |
| `JWT_PRIVATE_KEY_PEM` | Contenido de `private_key.pem` (con saltos de línea, entre comillas dobles) |
| `JWT_PUBLIC_KEY_PEM` | Contenido de `public_key.pem` (con saltos de línea, entre comillas dobles) |
| `GOOGLE_CLIENT_ID` | Client ID de Google OAuth |
| `GOOGLE_CLIENT_SECRET` | Client Secret de Google OAuth |
| `GOOGLE_REDIRECT_URI` | URI de redirección (ej. `http://localhost:8080/auth/callback/google`) |
| `ANTHROPIC_API_KEY` | API key de Anthropic (Claude) |

> **NUNCA** commitees el archivo `.env` al repositorio.

---

## 2. Backend (API + PostgreSQL + Redis)

### Iniciar todos los servicios

```bash
docker-compose up --build
```

La API queda disponible en `http://localhost:8080`.

### Iniciar en segundo plano

```bash
docker-compose up --build -d
```

### Detener

```bash
docker-compose down
```

### Ver logs de la API

```bash
docker-compose logs -f api
```

### Aplicar migraciones manualmente (si no se aplican automáticamente)

```bash
docker-compose exec api dotnet ef database update
```

### Correr tests del backend

```bash
dotnet test backend/tests/UnitTests
```

---

## 3. Mobile (Flutter)

### Emulador Android

```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

> En el emulador Android, `10.0.2.2` apunta al `localhost` del host.

### Simulador iOS / macOS

```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

### Dispositivo físico en la misma red

```bash
cd mobile
flutter run --dart-define=API_BASE_URL=http://<IP_LOCAL_DEL_HOST>:8080
```

Obtén tu IP local con `ipconfig` (Windows) o `ifconfig` / `ip addr` (macOS/Linux).

### Correr tests de Flutter

```bash
cd mobile
flutter test
```

### Build APK (Android release)

```bash
cd mobile
flutter build apk --dart-define=API_BASE_URL=https://api.situationist.app
```

### Build iOS (release)

```bash
cd mobile
flutter build ios --dart-define=API_BASE_URL=https://api.situationist.app
```

---

## 4. Flujo completo de desarrollo local

```bash
# Terminal 1 — Backend
docker-compose up --build

# Terminal 2 — Mobile (Android emulator)
cd mobile && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080


 Flutter Web → Firebase Hosting                                                                                                                 
  Desde mobile/:                                                                                                                               
  
  cd mobile
  flutter pub get
  flutter build web --release
  firebase deploy --only hosting --project the-situationist-7c23f

  La app quedará en https://the-situationist-7c23f.web.app.

  ---
  Android → Firebase App Distribution

  Primero activa App Distribution en Firebase Console → tu proyecto → App Distribution → click en Get started.

  Luego desde mobile/:

  # Construir el APK
  flutter build apk --release

  # Subir a App Distribution
  firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
    --app 1:621239065023:android:e9fdfe616ab0d798a2e90a \
    --release-notes "Primera versión" \
    --testers "correo@ejemplo.com" \
    --project the-situationist-7c23f

  Sustituye --testers con los correos de los testers separados por comas. Recibirán un email con el enlace de descarga.

  ---
  Commits pendientes

  Los archivos modificados hay que commitearlos:

  git add mobile/pubspec.yaml mobile/lib/main.dart mobile/firebase.json
  git commit -m "feat: add Firebase Core and configure Hosting + App Distribution"
  git push origin master
```
