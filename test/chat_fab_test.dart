import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_biblioteca/providers/auth_provider.dart';
import 'package:mi_biblioteca/providers/libros_provider.dart';
import 'package:mi_biblioteca/screens/chat_screen.dart';
import 'package:mi_biblioteca/screens/lista_libros_screen.dart';
import 'package:mi_biblioteca/services/auth_service.dart';
import 'package:mi_biblioteca/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/auth_service_falso.dart';
import 'helpers/repositorio_falso.dart';

Widget _crearApp(AuthService authService) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(service: authService)),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Sin sesión no se muestra el botón flotante IA', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(AuthServiceFalso()));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byTooltip('Abrir asistente IA'), findsNothing);
  });

  testWidgets('Con sesión aparece el botón IA y abre el chat', (tester) async {
    _pantallaAlta(tester);
    final servicio = AuthServiceFalso(
      usuarioInicial: const UsuarioSesion(
        uid: 'uid-1',
        correo: 'ana.perez@correo.com',
      ),
    );
    await tester.pumpWidget(_crearApp(servicio));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byTooltip('Abrir asistente IA'), findsOneWidget);

    await tester.tap(find.byTooltip('Abrir asistente IA'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Asistente IA'), findsOneWidget);
    expect(find.textContaining('¡Hola, Ana!'), findsOneWidget);
  });

  testWidgets(
    'El botón IA aparece al iniciar sesión y desaparece al cerrarla',
    (tester) async {
      _pantallaAlta(tester);
      await tester.pumpWidget(_crearApp(AuthServiceFalso()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'tu@correo.com'),
        'ana@correo.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mínimo 6 caracteres'),
        'lectura123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    },
  );
}
