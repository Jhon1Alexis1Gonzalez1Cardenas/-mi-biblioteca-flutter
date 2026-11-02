import 'package:flutter_test/flutter_test.dart';
import 'package:mi_biblioteca/providers/chat_provider.dart';
import 'package:mi_biblioteca/services/chat_service.dart';
import 'package:mi_biblioteca/services/configuracion_ia.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/chat_service_falso.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChatServiceFalso servicio;
  late ConfiguracionIA configuracion;
  late ChatProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    servicio = ChatServiceFalso();
    configuracion = ConfiguracionIA(
      preferencias: await SharedPreferences.getInstance(),
    );
    provider = ChatProvider(service: servicio, configuracion: configuracion);
  });

  test('Envía el mensaje y guarda la respuesta del asistente', () async {
    await provider.enviar('Recomiéndame un libro');

    expect(provider.mensajes.length, 2);
    expect(provider.mensajes.first.esDelUsuario, isTrue);
    expect(provider.mensajes.first.contenido, 'Recomiéndame un libro');
    expect(provider.mensajes.last.esDelUsuario, isFalse);
    expect(provider.mensajes.last.contenido, 'Respuesta simulada del asistente.');
    expect(provider.enviando, isFalse);
    expect(provider.error, isNull);
  });

  test('Envía el historial completo en cada petición', () async {
    await provider.enviar('Hola');
    await provider.enviar('¿Qué leo después?');

    expect(servicio.llamadas, 2);
    expect(servicio.historialesRecibidos.last.length, 3);
  });

  test('No envía mensajes vacíos ni solo espacios', () async {
    await provider.enviar('');
    await provider.enviar('   ');

    expect(servicio.llamadas, 0);
    expect(provider.mensajes, isEmpty);
  });

  test('Muestra el error y reintentar vuelve a pedir la respuesta', () async {
    servicio.error = const ChatException('No se pudo conectar.');

    await provider.enviar('Hola');

    expect(provider.error, 'No se pudo conectar.');
    expect(provider.enviando, isFalse);
    expect(provider.mensajes.length, 1);

    servicio.error = null;
    await provider.reintentar();

    expect(provider.error, isNull);
    expect(provider.mensajes.length, 2);
    expect(provider.mensajes.last.esDelUsuario, isFalse);
    expect(servicio.llamadas, 2);
  });

  test('No reintenta si el último mensaje no es del usuario', () async {
    await provider.enviar('Hola');
    final llamadasAntes = servicio.llamadas;

    await provider.reintentar();

    expect(servicio.llamadas, llamadasAntes);
  });

  test('Guarda una URL válida y la conserva en la configuración', () async {
    final guardado = await provider.guardarUrlServidor(
      'http://192.168.1.50:11434',
    );

    expect(guardado, isTrue);
    expect(provider.urlServidor, 'http://192.168.1.50:11434');
    expect(await configuracion.obtenerUrl(), 'http://192.168.1.50:11434');
  });

  test('Rechaza una URL que no empieza por http:// o https://', () async {
    final guardado = await provider.guardarUrlServidor('192.168.1.50:11434');

    expect(guardado, isFalse);
    expect(provider.urlServidor, ConfiguracionIA.urlPorDefecto);
    expect(await configuracion.obtenerUrl(), ConfiguracionIA.urlPorDefecto);
  });

  test('Restablece la URL por defecto', () async {
    await provider.guardarUrlServidor('https://mi-servidor.local:11434');
    expect(provider.urlServidor, 'https://mi-servidor.local:11434');

    await provider.restablecerUrlServidor();

    expect(provider.urlServidor, ConfiguracionIA.urlPorDefecto);
    expect(await configuracion.obtenerUrl(), ConfiguracionIA.urlPorDefecto);
  });

  test('Carga la URL guardada al iniciar', () async {
    await configuracion.guardarUrl('http://10.0.2.2:11434');
    await provider.cargarConfiguracion();

    expect(provider.urlServidor, 'http://10.0.2.2:11434');
  });
}
