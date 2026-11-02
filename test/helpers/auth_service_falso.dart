import 'dart:async';

import 'package:mi_biblioteca/services/auth_service.dart';

/// Simulación de AuthService para pruebas, sin Firebase.
class AuthServiceFalso implements AuthService {
  AuthServiceFalso({UsuarioSesion? usuarioInicial}) : _usuario = usuarioInicial;

  final StreamController<UsuarioSesion?> _estado =
      StreamController<UsuarioSesion?>.broadcast();

  UsuarioSesion? _usuario;

  AuthException? errorAlIniciar;
  AuthException? errorAlRegistrar;
  AuthException? errorAlCerrar;

  String? ultimoCorreo;
  String? ultimaContrasena;
  int vecesCerrada = 0;

  /// Retraso simulado para poder observar el estado "Validando...".
  Duration demora = Duration.zero;

  @override
  Stream<UsuarioSesion?> get authStateChanges => _estado.stream;

  @override
  UsuarioSesion? get usuarioActual => _usuario;

  /// Simula un cambio de sesión externo (por ejemplo, al restaurar la sesión).
  void emitir(UsuarioSesion? usuario) {
    _usuario = usuario;
    _estado.add(usuario);
  }

  @override
  Future<UsuarioSesion> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    ultimoCorreo = correo;
    ultimaContrasena = contrasena;
    if (demora > Duration.zero) await Future<void>.delayed(demora);
    if (errorAlIniciar != null) throw errorAlIniciar!;

    final usuario = UsuarioSesion(uid: 'uid-1', correo: correo);
    emitir(usuario);
    return usuario;
  }

  @override
  Future<UsuarioSesion> registrar({
    required String correo,
    required String contrasena,
  }) async {
    ultimoCorreo = correo;
    ultimaContrasena = contrasena;
    if (demora > Duration.zero) await Future<void>.delayed(demora);
    if (errorAlRegistrar != null) throw errorAlRegistrar!;

    final usuario = UsuarioSesion(uid: 'uid-2', correo: correo);
    emitir(usuario);
    return usuario;
  }

  @override
  Future<void> cerrarSesion() async {
    vecesCerrada++;
    if (errorAlCerrar != null) throw errorAlCerrar!;
    emitir(null);
  }

  void cerrar() {
    _estado.close();
  }
}
