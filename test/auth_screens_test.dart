import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mi_biblioteca/providers/auth_provider.dart';
import 'package:mi_biblioteca/providers/libros_provider.dart';
import 'package:mi_biblioteca/screens/lista_libros_screen.dart';
import 'package:mi_biblioteca/services/auth_service.dart';
import 'package:mi_biblioteca/theme/app_theme.dart';

import 'helpers/auth_service_falso.dart';
import 'helpers/repositorio_falso.dart';

Widget _crearApp(AuthService authService) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(service: authService),
      ),
      ChangeNotifierProvider(
        create: (_) => LibrosProvider(repository: RepositorioFalso()),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const ListaLibrosScreen(),
    ),
  );
}

void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _abrirLogin(WidgetTester tester) async {
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pumpAndSettle();
}

Future<void> _llenarLogin(
  WidgetTester tester, {
  String correo = 'ana@correo.com',
  String contrasena = 'lectura123',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'tu@correo.com'),
    correo,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Mínimo 6 caracteres'),
    contrasena,
  );
}

void main() {
  testWidgets('Sin sesión la lista muestra el botón Iniciar sesión',
      (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(AuthServiceFalso()));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Mi Biblioteca'), findsOneWidget);
  });

  testWidgets('El CRUD está disponible sin iniciar sesión', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(AuthServiceFalso()));
    await tester.pumpAndSettle();

    expect(find.text('Agregar libro'), findsOneWidget);
  });

  testWidgets('Login valida correo y contraseña vacíos', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(AuthServiceFalso()));
    await tester.pumpAndSettle();

    await _abrirLogin(tester);
    expect(find.text('Accede a tu biblioteca personal'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
    expect(find.text('La contraseña es obligatoria'), findsOneWidget);
  });

  testWidgets('Login muestra el error de credenciales incorrectas',
      (tester) async {
    _pantallaAlta(tester);
    final servicio = AuthServiceFalso()
      ..errorAlIniciar = const AuthException(
        'Correo o contraseña incorrectos.',
      );
    await tester.pumpWidget(_crearApp(servicio));
    await tester.pumpAndSettle();

    await _abrirLogin(tester);
    await _llenarLogin(tester, contrasena: 'incorrecta');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('Mientras responde muestra Validando...', (tester) async {
    _pantallaAlta(tester);
    final servicio = AuthServiceFalso()
      ..demora = const Duration(milliseconds: 300);
    await tester.pumpWidget(_crearApp(servicio));
    await tester.pumpAndSettle();

    await _abrirLogin(tester);
    await _llenarLogin(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pump();

    expect(find.text('Validando...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  });

  testWidgets('Al iniciar sesión vuelve a la lista con el avatar',
      (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(AuthServiceFalso()));
    await tester.pumpAndSettle();

    await _abrirLogin(tester);
    await _llenarLogin(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Sesión iniciada'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
  });

  testWidgets('El menú del avatar muestra el correo y cierra sesión',
      (tester) async {
    _pantallaAlta(tester);
    final servicio = AuthServiceFalso(
      usuarioInicial: const UsuarioSesion(
        uid: 'uid-1',
        correo: 'alexis@correo.com',
      ),
    );
    await tester.pumpWidget(_crearApp(servicio));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(find.text('alexis@correo.com'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(servicio.vecesCerrada, 1);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('Registro avisa cuando las contraseñas no coinciden',
      (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(AuthServiceFalso()));
    await tester.pumpAndSettle();

    await _abrirLogin(tester);
    await tester.tap(find.text('Regístrate aquí'));
    await tester.pumpAndSettle();

    expect(
      find.text('Regístrate para empezar a usar Mi Biblioteca'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'tu@correo.com'),
      'lucia@correo.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mínimo 6 caracteres'),
      'Lectura2026',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Repite tu contraseña'),
      'Lectura2025',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });

  testWidgets('Registro muestra el error de correo ya registrado',
      (tester) async {
    _pantallaAlta(tester);
    final servicio = AuthServiceFalso()
      ..errorAlRegistrar = const AuthException(
        'Este correo ya está registrado.',
      );
    await tester.pumpWidget(_crearApp(servicio));
    await tester.pumpAndSettle();

    await _abrirLogin(tester);
    await tester.tap(find.text('Regístrate aquí'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'tu@correo.com'),
      'ana@correo.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mínimo 6 caracteres'),
      'lectura2026',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Repite tu contraseña'),
      'lectura2026',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Este correo ya está registrado.'), findsOneWidget);
  });
}
