# Mi Biblioteca

App móvil en Flutter (Android) para llevar una biblioteca personal: registrar libros y controlar su estado de lectura. Proyecto universitario (UCEVA), desarrollador único. Fecha límite: 21 de noviembre de 2026.

Idea central: la app funciona completa SIN cuenta. El inicio de sesión existe únicamente para habilitar el botón del chat con un asistente de IA.

## Alcance (no salirse de esto)

Incluye:
- CRUD de libros sin necesidad de iniciar sesión: agregar, listar, ver detalle, editar, eliminar.
- Estado de lectura: Pendiente, Leyendo, Terminado.
- Búsqueda por título o autor y filtro por estado.
- Datos guardados localmente en SQLite (sqflite).
- En la pantalla de lista, botón "Iniciar sesión" en la esquina superior izquierda (lleva a Login, con enlace a Registro). Cuando hay sesión, ese botón pasa a ser un avatar con menú "Cerrar sesión" y aparece un botón flotante en la esquina inferior derecha (icono de mensaje con las letras "IA") que abre el chat.
- Login y registro con correo/contraseña usando Firebase Authentication. Solo sirven para desbloquear el chat.
- Chat con un asistente de IA sobre lectura (recomendar libros, resumir, resolver dudas), usando un modelo de lenguaje LOCAL servido por Ollama en el computador del desarrollador (API HTTP, sin servicios de IA en la nube). El historial del chat vive solo en memoria, no se guarda.

No incluye (no agregar sin que se pida): exigir sesión para usar el CRUD, Firestore u otra base en la nube, guardar conversaciones, enviar la biblioteca del usuario a la IA, API externa de libros, escáner, préstamos, notificaciones, funciones sociales, recuperación de contraseña real.

## Stack

- Flutter + Dart, solo Android como objetivo.
- Estado: Provider.
- Base de datos local: sqflite (+ path).
- Autenticación: firebase_core + firebase_auth.
- IA: Ollama local (API REST en http://<IP-del-PC>:11434, endpoint /api/chat) consumida con el paquete http. En el emulador Android el PC es 10.0.2.2; en un celular físico se usa la IP de la red local. La URL base y el nombre del modelo van en una constante/config fácil de cambiar (no hardcodeadas por toda la app).

## Arquitectura por capas

```
lib/
  main.dart
  models/        libro.dart (clase Libro, toMap/fromMap), mensaje_chat.dart
  data/          database_helper.dart, libro_repository.dart
  services/      auth_service.dart (único lugar que habla con FirebaseAuth)
                 chat_service.dart (único lugar que habla con el servidor de IA local)
  providers/     libros_provider.dart, auth_provider.dart, chat_provider.dart
  screens/       lista, agregar, detalle, editar, login, registro, chat
  widgets/       componentes reutilizables
  theme/         colores y estilos tomados del prototipo
```

Reglas de capas: la UI nunca toca SQLite, FirebaseAuth ni el servidor de IA directamente; pasa por Provider. Solo `libro_repository.dart` lee/escribe en SQLite. Solo `auth_service.dart` usa FirebaseAuth. Solo `chat_service.dart` habla con el servidor de IA (Ollama).

## Modelo de datos

Tabla `libros`: id (PK autoincrement), titulo, autor, genero, anioPublicacion (entero), estadoLectura ('Pendiente' | 'Leyendo' | 'Terminado'). Sin campo de usuario: los libros no dependen de la cuenta.

## Flujo de pantallas

La app abre directo en Lista (no exige sesión). Lista -> Detalle -> Editar; Lista -> Agregar.
Sin sesión: botón "Iniciar sesión" (arriba a la izquierda) -> Login (<-> Registro) -> al autenticarse vuelve a Lista ya con sesión. Login y Registro tienen flecha de volver a Lista.
Con sesión: avatar arriba a la izquierda (menú con "Cerrar sesión") y botón flotante "IA" abajo a la derecha -> Chat. Al cerrar sesión desaparece el botón "IA" y vuelve el botón "Iniciar sesión".

## Chat con IA

Pantalla simple: burbujas de mensajes, campo de texto, botón enviar, indicador de "escribiendo". Instrucción de sistema: asistente de lectura que responde en español, recomienda y resume libros, y avisa cuando no está seguro de un dato en vez de inventarlo. Manejar errores y servidor no disponible (PC apagado, fuera de la red, Ollama sin iniciar) con un mensaje claro y botón Reintentar. Android requiere permiso INTERNET y, al usar http (no https) hacia la red local, habilitar cleartext traffic para ese host.

## Diseño

Seguir el prototipo de Figma (capturas en `docs/prototipo/`): fondo lavanda muy claro, tarjetas blancas con bordes suaves, botón principal morado sólido, chips de estado (Pendiente gris, Leyendo azul, Terminado verde). Para la pantalla de chat y el botón flotante "IA", seguir las capturas nuevas en `docs/prototipo/` o, si no hay, mantener el mismo estilo. El botón flotante no debe tapar contenido: dejar padding inferior en la lista. Textos de la UI en español.

## Reglas de trabajo

- Trabajar UNA etapa a la vez, solo la que se pida. No adelantar etapas.
- Git: GitHub Flow. Nunca commitear ni hacer push a `main`. Cada etapa va en una rama `feature/<nombre-corto>`. Commits pequeños y descriptivos.
- No subir al repo `google-services.json`, `firebase_options.dart` ni `.env` (deben estar en `.gitignore`).
- Código limpio: nombres descriptivos y consistentes, funciones cortas, una responsabilidad por clase.
- Antes de dar una etapa por terminada: `flutter analyze` sin errores y `flutter test` en verde.
- Validar entradas: no guardar libros sin título ni autor; contraseña mínimo 6 caracteres; confirmar que las contraseñas coinciden; no enviar mensajes vacíos al chat.
- Si algo requiere una acción manual del desarrollador (consola de Firebase, `flutterfire configure`, instalar/iniciar Ollama y descargar el modelo con `ollama pull`, exponer Ollama en la red con OLLAMA_HOST=0.0.0.0), detenerse y decirlo en vez de inventar valores.

## Etapas (en este orden)

1. Configuración: proyecto Flutter, dependencias, estructura de carpetas, tema, esquema SQLite, Firebase inicializado.
2. CRUD básico: agregar y listar libros.
3. CRUD completo: detalle, editar, eliminar, cambio de estado de lectura.
4. Búsqueda por título/autor y filtro por estado.
5. Autenticación (Firebase): login, registro, cerrar sesión, manejo de errores; botón "Iniciar sesión" / avatar en la Lista, que cambia según haya sesión (escuchar authStateChanges).
6. Chat con el asistente de IA y botón flotante "IA" visible solo con sesión.
7. Pulido (estados vacíos, errores, ajustes de interfaz) y pruebas (repositorio, widget de la lista, flujo de login).
