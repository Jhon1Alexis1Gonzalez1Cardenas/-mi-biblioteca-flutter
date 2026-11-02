import 'package:flutter/foundation.dart';

import '../models/mensaje_chat.dart';
import '../services/chat_service.dart';
import '../services/configuracion_ia.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ChatService? service, ConfiguracionIA? configuracion})
    : _service = service ?? OllamaChatService(),
      _configuracion = configuracion ?? ConfiguracionIA();

  final ChatService _service;
  final ConfiguracionIA _configuracion;

  final List<MensajeChat> _mensajes = [];
  bool _enviando = false;
  bool _descartado = false;
  String? _error;
  String _urlServidor = ConfiguracionIA.urlPorDefecto;

  List<MensajeChat> get mensajes => List.unmodifiable(_mensajes);
  bool get enviando => _enviando;
  String? get error => _error;
  String get urlServidor => _urlServidor;
  bool get tieneMensajes => _mensajes.isNotEmpty;

  /// Evita notificar después de que la pantalla del chat se cerró.
  void _notificar() {
    if (!_descartado) notifyListeners();
  }

  /// Carga la URL del servidor guardada en el dispositivo.
  Future<void> cargarConfiguracion() async {
    try {
      _urlServidor = await _configuracion.obtenerUrl();
    } catch (_) {
      _urlServidor = ConfiguracionIA.urlPorDefecto;
    }
    _notificar();
  }

  Future<bool> guardarUrlServidor(String url) async {
    if (!ConfiguracionIA.esUrlValida(url)) return false;

    try {
      await _configuracion.guardarUrl(url);
    } catch (_) {
      return false;
    }

    _urlServidor = url.trim();
    _notificar();
    return true;
  }

  Future<void> restablecerUrlServidor() async {
    try {
      await _configuracion.restablecerUrl();
    } catch (_) {
      // Si falla el guardado, al menos se usa el valor por defecto.
    }
    _urlServidor = ConfiguracionIA.urlPorDefecto;
    _notificar();
  }

  /// Agrega el mensaje del usuario y pide la respuesta del asistente.
  /// El historial vive solo en memoria: no se guarda en el dispositivo.
  Future<void> enviar(String texto) async {
    final mensaje = texto.trim();
    if (mensaje.isEmpty || _enviando) return;

    _mensajes.add(MensajeChat.usuario(mensaje));
    await _solicitarRespuesta();
  }

  /// Vuelve a pedir la respuesta al último mensaje del usuario.
  Future<void> reintentar() async {
    if (_enviando || _mensajes.isEmpty) return;
    if (!_mensajes.last.esDelUsuario) return;
    await _solicitarRespuesta();
  }

  Future<void> _solicitarRespuesta() async {
    _enviando = true;
    _error = null;
    _notificar();

    try {
      final respuesta = await _service.enviarMensaje(List.of(_mensajes));
      _mensajes.add(MensajeChat.asistente(respuesta));
    } on ChatException catch (error) {
      _error = error.mensaje;
    } catch (_) {
      _error = 'Ocurrió un error al hablar con el asistente. Intenta de nuevo.';
    } finally {
      _enviando = false;
      _notificar();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
