import 'package:mi_biblioteca/models/mensaje_chat.dart';
import 'package:mi_biblioteca/services/chat_service.dart';

/// Simulación de ChatService para pruebas, sin servidor real.
class ChatServiceFalso implements ChatService {
  ChatServiceFalso({this.respuesta = 'Respuesta simulada del asistente.'});

  String respuesta;
  ChatException? error;

  /// Retraso simulado para poder observar el indicador "escribiendo...".
  Duration demora = Duration.zero;

  int llamadas = 0;
  final List<List<MensajeChat>> historialesRecibidos = [];

  @override
  Future<String> enviarMensaje(List<MensajeChat> historial) async {
    llamadas++;
    historialesRecibidos.add(List.of(historial));

    if (demora > Duration.zero) await Future<void>.delayed(demora);
    if (error != null) throw error!;

    return respuesta;
  }
}
