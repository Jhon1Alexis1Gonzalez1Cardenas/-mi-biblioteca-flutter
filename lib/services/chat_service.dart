import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/mensaje_chat.dart';
import 'configuracion_ia.dart';

/// Error del asistente con un mensaje listo para mostrar en la UI.
class ChatException implements Exception {
  const ChatException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato del asistente para poder simularlo en las pruebas.
abstract class ChatService {
  Future<String> enviarMensaje(List<MensajeChat> historial);
}

/// Único lugar de la app que habla con el servidor local de IA (Ollama).
class OllamaChatService implements ChatService {
  OllamaChatService({
    ConfiguracionIA? configuracion,
    http.Client? cliente,
    this.tiempoEspera = const Duration(seconds: 60),
  })  : _configuracion = configuracion ?? ConfiguracionIA(),
        _cliente = cliente ?? http.Client();

  static const String instruccionSistema =
      'Eres un asistente de lectura que responde siempre en español. '
      'Recomiendas y resumes libros, y ayudas a decidir qué leer después. '
      'Si no estás seguro de un dato (un detalle del argumento, el año, '
      'el autor o cualquier otro), dilo claramente en lugar de inventarlo.';

  final ConfiguracionIA _configuracion;
  final http.Client _cliente;
  final Duration tiempoEspera;

  @override
  Future<String> enviarMensaje(List<MensajeChat> historial) async {
    final urlBase = (await _configuracion.obtenerUrl()).trim();
    final url = Uri.parse(
      '${urlBase.replaceFirst(RegExp(r'/+$'), '')}/api/chat',
    );

    final cuerpo = {
      'model': ConfiguracionIA.modelo,
      'stream': false,
      'messages': [
        {
          'role': 'system',
          'content': instruccionSistema,
        },
        ...historial.map((mensaje) => mensaje.toApiJson()),
      ],
    };

    try {
      final respuesta = await _cliente
          .post(
            url,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(cuerpo),
          )
          .timeout(tiempoEspera);

      if (respuesta.statusCode != 200) {
        throw ChatException(
          'El servidor de IA respondió con un error '
          '(${respuesta.statusCode}). Intenta de nuevo.',
        );
      }

      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      final mensaje = datos is Map<String, dynamic> ? datos['message'] : null;
      final contenido = mensaje is Map<String, dynamic>
          ? mensaje['content']
          : null;

      if (contenido is! String || contenido.trim().isEmpty) {
        throw const ChatException(
          'El asistente no devolvió una respuesta. Intenta de nuevo.',
        );
      }

      return contenido.trim();
    } on TimeoutException {
      throw const ChatException(
        'El asistente tardó demasiado en responder. '
        'Revisa que Ollama esté activo e intenta de nuevo.',
      );
    } on SocketException {
      throw const ChatException(
        'No se pudo conectar con el servidor de IA. Revisa que el PC esté '
        'encendido, que Ollama esté iniciado y que la URL sea correcta.',
      );
    } on http.ClientException {
      throw const ChatException(
        'No se pudo conectar con el servidor de IA. Revisa la URL y tu red.',
      );
    } on FormatException {
      throw const ChatException(
        'El servidor de IA devolvió una respuesta inesperada. Intenta de nuevo.',
      );
    }
  }
}
