import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_biblioteca/screens/chat_screen.dart';
import 'package:mi_biblioteca/services/chat_service.dart';
import 'package:mi_biblioteca/services/configuracion_ia.dart';
import 'package:mi_biblioteca/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/chat_service_falso.dart';

Widget _crearChat({
  ChatService? servicio,
  ConfiguracionIA? configuracion,
  String? nombreUsuario,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: ChatScreen(
      chatService: servicio ?? ChatServiceFalso(),
      configuracion: configuracion,
      nombreUsuario: nombreUsuario,
    ),
  );
}

void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _enviarTexto(WidgetTester tester, String texto) async {
  await tester.enterText(find.byType(TextField), texto);
  await tester.tap(find.byIcon(Icons.arrow_upward));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConfiguracionIA configuracion;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    configuracion = ConfiguracionIA(
      preferencias: await SharedPreferences.getInstance(),
    );
  });

  testWidgets('Muestra la bienvenida con preguntas sugeridas', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(
      _crearChat(configuracion: configuracion, nombreUsuario: 'Ana'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Asistente IA'), findsOneWidget);
    expect(find.textContaining('¡Hola, Ana!'), findsOneWidget);
    expect(find.text('Recomiéndame un libro'), findsOneWidget);
    expect(find.text('Resume un libro'), findsOneWidget);
    expect(find.text('¿Qué leo después?'), findsOneWidget);
  });

  testWidgets('Envía un mensaje y muestra la respuesta del asistente',
      (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(
      _crearChat(
        servicio: ChatServiceFalso(respuesta: 'Te recomiendo "Dune".'),
        configuracion: configuracion,
      ),
    );
    await tester.pumpAndSettle();

    await _enviarTexto(tester, 'Recomiéndame un libro');

    expect(find.text('Recomiéndame un libro'), findsWidgets);
    expect(find.text('Te recomiendo "Dune".'), findsOneWidget);
  });

  testWidgets('Al tocar una sugerencia la envía como mensaje', (tester) async {
    _pantallaAlta(tester);
    final servicio = ChatServiceFalso(respuesta: 'Claro, aquí va.');
    await tester.pumpWidget(
      _crearChat(servicio: servicio, configuracion: configuracion),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume un libro'));
    await tester.pumpAndSettle();

    expect(servicio.llamadas, 1);
    expect(servicio.historialesRecibidos.first.single.contenido,
        'Resume un libro');
    expect(find.text('Claro, aquí va.'), findsOneWidget);
  });

  testWidgets('Muestra "escribiendo..." mientras espera la respuesta',
      (tester) async {
    _pantallaAlta(tester);
    final servicio = ChatServiceFalso()
      ..demora = const Duration(milliseconds: 300);
    await tester.pumpWidget(
      _crearChat(servicio: servicio, configuracion: configuracion),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hola');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();

    expect(find.text('escribiendo...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('escribiendo...'), findsNothing);
  });

  testWidgets('No envía mensajes vacíos', (tester) async {
    _pantallaAlta(tester);
    final servicio = ChatServiceFalso();
    await tester.pumpWidget(
      _crearChat(servicio: servicio, configuracion: configuracion),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    expect(servicio.llamadas, 0);
  });

  testWidgets('Muestra el error y permite reintentar', (tester) async {
    _pantallaAlta(tester);
    final servicio = ChatServiceFalso(respuesta: 'Ahora sí funciona.')
      ..error = const ChatException(
        'No se pudo conectar con el servidor de IA.',
      );
    await tester.pumpWidget(
      _crearChat(servicio: servicio, configuracion: configuracion),
    );
    await tester.pumpAndSettle();

    await _enviarTexto(tester, 'Hola');

    expect(
      find.text('No se pudo conectar con el servidor de IA.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);

    servicio.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Reintentar'), findsNothing);
    expect(find.text('Ahora sí funciona.'), findsOneWidget);
  });

  testWidgets('El diálogo de ajustes muestra la URL actual', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearChat(configuracion: configuracion));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Servidor de IA'), findsOneWidget);
    expect(find.text(ConfiguracionIA.urlPorDefecto), findsWidgets);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.text('Restablecer'), findsOneWidget);
  });

  testWidgets('Guarda una URL válida desde el diálogo', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearChat(configuracion: configuracion));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'http://192.168.1.50:11434',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Servidor guardado'), findsOneWidget);
    expect(await configuracion.obtenerUrl(), 'http://192.168.1.50:11434');
  });

  testWidgets('Avisa cuando la URL no empieza por http', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearChat(configuracion: configuracion));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '192.168.1.50:11434');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Debe empezar por http:// o https://'),
      findsWidgets,
    );
    expect(await configuracion.obtenerUrl(), ConfiguracionIA.urlPorDefecto);
  });

  testWidgets('Restablece la URL por defecto', (tester) async {
    _pantallaAlta(tester);
    await configuracion.guardarUrl('http://192.168.1.50:11434');
    await tester.pumpWidget(_crearChat(configuracion: configuracion));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restablecer'));
    await tester.pumpAndSettle();

    expect(find.text('Servidor restablecido al valor por defecto'),
        findsOneWidget);
    expect(await configuracion.obtenerUrl(), ConfiguracionIA.urlPorDefecto);
  });
}
