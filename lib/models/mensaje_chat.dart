enum RolMensaje { usuario, asistente }

class MensajeChat {
  const MensajeChat({required this.rol, required this.contenido});

  const MensajeChat.usuario(this.contenido) : rol = RolMensaje.usuario;

  const MensajeChat.asistente(this.contenido) : rol = RolMensaje.asistente;

  final RolMensaje rol;
  final String contenido;

  bool get esDelUsuario => rol == RolMensaje.usuario;

  /// Nombre del rol tal como lo espera la API de Ollama.
  String get rolApi => esDelUsuario ? 'user' : 'assistant';

  Map<String, dynamic> toApiJson() => {
        'role': rolApi,
        'content': contenido,
      };
}
