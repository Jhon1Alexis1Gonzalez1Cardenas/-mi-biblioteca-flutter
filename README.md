# Mi Biblioteca

Aplicación móvil en Flutter (Android) para llevar una biblioteca personal: registrar libros, buscar y filtrar, y controlar su estado de lectura (**Pendiente**, **Leyendo**, **Terminado**).

La app funciona completa **sin cuenta**. El inicio de sesión con Firebase existe únicamente para habilitar el chat con un asistente de IA que corre en local mediante Ollama.

Proyecto universitario (UCEVA).

## Funcionalidades

- CRUD de libros sin necesidad de iniciar sesión: agregar, listar, ver detalle, editar y eliminar.
- Estado de lectura con chips de color: Pendiente (gris), Leyendo (azul), Terminado (verde).
- Búsqueda por título o autor y filtro por estado, combinables.
- Datos guardados localmente en SQLite (`sqflite`).
- Login y registro con correo/contraseña (Firebase Authentication) solo para desbloquear el chat.
- Avatar con menú de cuenta y cierre de sesión cuando hay sesión iniciada.
- Chat con un asistente de lectura servido por un modelo local de Ollama (`qwen2.5:3b`). El historial vive solo en memoria.
- La URL del servidor de IA se puede cambiar desde el icono de ajustes del chat y se guarda con `shared_preferences`.

## Capturas

Las imágenes de referencia del diseño están en [`docs/prototipo/`](docs/prototipo/).

| Lista sin sesión | Lista con sesión | Detalle del libro |
| --- | --- | --- |
| ![Lista sin sesión](<docs/prototipo/Lista de libros · Sin sesión.png>) | ![Lista con sesión](<docs/prototipo/Lista de libros · Con sesión.png>) | ![Detalle del libro](docs/prototipo/Detalle%20del%20libro.png) |

| Agregar libro | Editar libro | Chat con IA |
| --- | --- | --- |
| ![Agregar libro](docs/prototipo/Agregar%20libro.png) | ![Editar libro](docs/prototipo/Editar%20libro.png) | ![Asistente IA](<docs/prototipo/Asistente IA · Inicial.png>) |

## Tecnologías

- Flutter + Dart (Android).
- Estado con `provider`.
- Base de datos local con `sqflite` + `path`.
- Autenticación con `firebase_core` + `firebase_auth`.
- Chat con `http` contra la API de Ollama (`/api/chat`).
- Preferencias con `shared_preferences`.

## Estructura del proyecto

```
lib/
  main.dart
  models/        libro.dart, mensaje_chat.dart
  data/          database_helper.dart, libro_repository.dart
  services/      auth_service.dart, chat_service.dart, configuracion_ia.dart
  providers/     libros_provider.dart, auth_provider.dart, chat_provider.dart
  screens/       lista, agregar, detalle, editar, login, registro, chat
  widgets/       componentes reutilizables
  theme/         colores y estilos
```

Reglas de capas:

- La UI nunca toca SQLite, FirebaseAuth ni el servidor de IA directamente; siempre pasa por un `Provider`.
- Solo `libro_repository.dart` lee y escribe en SQLite.
- Solo `auth_service.dart` usa FirebaseAuth.
- Solo `chat_service.dart` habla con Ollama.

## Requisitos

- Flutter SDK 3.x (Dart 3.13 o superior) con soporte para Android.
- Android Studio / Android SDK y un emulador o un celular físico.
- Un proyecto de Firebase con el proveedor **Correo electrónico/contraseña** habilitado.
- [Ollama](https://ollama.com/) instalado en el computador donde se ejecutará el modelo local.

## Configuración de Firebase

Los archivos `android/app/google-services.json` y `lib/firebase_options.dart` **no se suben al repositorio** (están en `.gitignore`); cada desarrollador debe generarlos.

1. Crea un proyecto en la [consola de Firebase](https://console.firebase.google.com/).
2. En **Authentication → Sign-in method**, habilita **Correo electrónico/contraseña**.
3. Instala la CLI de FlutterFire:

   ```bash
   dart pub global activate flutterfire_cli
   ```

4. Desde la raíz del proyecto, vincula la app de Android:

   ```bash
   flutterfire configure
   ```

   Esto genera `lib/firebase_options.dart` y `android/app/google-services.json`. El proyecto ya tiene aplicado el plugin `com.google.gms.google-services`, así que `Firebase.initializeApp()` funciona con esa configuración.

5. Verifica que `android/app/google-services.json` exista antes de compilar.

## Configuración de Ollama

1. Instala Ollama y descarga el modelo:

   ```bash
   ollama pull qwen2.5:3b
   ```

2. Expón Ollama en la red local para que el emulador o el celular puedan conectarse.

   - Windows (PowerShell):

     ```powershell
     $env:OLLAMA_HOST = "0.0.0.0"
     ollama serve
     ```

   - macOS / Linux:

     ```bash
     OLLAMA_HOST=0.0.0.0 ollama serve
     ```

3. Comprueba que responde en el computador:

   ```bash
   curl http://localhost:11434/api/tags
   ```

4. Configura la URL desde la app:

   - **Emulador de Android:** la URL por defecto es `http://10.0.2.2:11434` (10.0.2.2 es el PC visto desde el emulador).
   - **Celular físico:** abre el chat, toca el icono de ajustes (⚙) del encabezado, escribe `http://<IP-de-tu-PC>:11434` (por ejemplo, `http://192.168.1.50:11434`) y pulsa **Guardar**. El celular y el PC deben estar en la misma red.
   - Si el PC tiene firewall, permite el puerto `11434`.

El modelo y la URL por defecto están centralizados en `lib/services/configuracion_ia.dart`.

## Cómo correr la app

```bash
flutter pub get
flutter run
```

La app abre directamente en la lista de libros. El CRUD funciona sin iniciar sesión; el botón flotante **IA** aparece únicamente cuando hay sesión.

Para generar un APK de depuración:

```bash
flutter build apk --debug
```

El APK queda en `build/app/outputs/flutter-apk/app-debug.apk`.

## Pruebas

```bash
flutter analyze
flutter test
```

Las pruebas usan servicios y repositorios simulados para no depender de Firebase, Ollama ni un dispositivo:

- `test/libro_repository_test.dart`: SQLite en memoria (insertar, listar, actualizar, eliminar, orden y búsqueda sobre los datos guardados).
- `test/libros_provider_test.dart`: búsqueda, filtros, estados de error y sincronización de la lista.
- `test/widget_test.dart`: widget de la lista, estados vacío/error, agregar, detalle, editar, eliminar y búsqueda.
- `test/auth_provider_test.dart` y `test/auth_screens_test.dart`: flujo de login/registro y mensajes de error.
- `test/chat_provider_test.dart` y `test/chat_screens_test.dart`: chat con `ChatService` simulado, indicador "escribiendo...", reintento y ajustes del servidor.
- `test/chat_fab_test.dart`: el botón **IA** aparece y desaparece según la sesión.

## Flujo de ramas (GitHub Flow)

1. `main` siempre contiene código estable y funcional. **No se hace push directo a `main`.**
2. Cada etapa o corrección se desarrolla en una rama `feature/<nombre-corto>` creada desde `main` actualizado.
3. Los commits son pequeños y descriptivos.
4. Al terminar, se abre un **Pull Request** hacia `main`; requiere al menos una revisión aprobada.
5. Después de fusionar, la rama `feature/...` se elimina.

## Notas sobre HTTP en claro

El chat usa `http://` hacia la red local, por lo que `android/app/src/main/res/xml/network_security_config.xml` permite tráfico en claro. Android **no permite** expresar rangos de red privada (por ejemplo `192.168.0.0/16`) en esta configuración: solo acepta hosts o IPs concretas. Como la URL del servidor se puede cambiar desde la app para usar la IP del PC, una lista fija rompería el chat en un celular físico; por eso se deja habilitado y se documenta aquí.

## Alcance

No incluye (por ahora): exigir sesión para el CRUD, Firestore u otra base en la nube, guardar conversaciones, enviar la biblioteca del usuario a la IA, API externa de libros, escáner, préstamos, notificaciones, funciones sociales ni recuperación real de contraseña.
