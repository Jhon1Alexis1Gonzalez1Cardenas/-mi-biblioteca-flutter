import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service})
      : _service = service ?? FirebaseAuthService() {
    _usuario = _service.usuarioActual;
    _suscripcion = _service.authStateChanges.listen(
      (usuario) {
        _usuario = usuario;
        _cargando = false;
        notifyListeners();
      },
      onError: (_) {
        _cargando = false;
        notifyListeners();
      },
    );
  }

  final AuthService _service;
  late final StreamSubscription<UsuarioSesion?> _suscripcion;

  UsuarioSesion? _usuario;
  bool _cargando = false;
  String? _error;

  UsuarioSesion? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get cargando => _cargando;
  String? get error => _error;

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) {
    return _ejecutar(
      () => _service.iniciarSesion(correo: correo, contrasena: contrasena),
    );
  }

  Future<bool> registrar({
    required String correo,
    required String contrasena,
  }) {
    return _ejecutar(
      () => _service.registrar(correo: correo, contrasena: contrasena),
    );
  }

  Future<bool> cerrarSesion() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _service.cerrarSesion();
      _usuario = null;
      return true;
    } on AuthException catch (error) {
      _error = error.mensaje;
      return false;
    } catch (_) {
      _error = 'No se pudo cerrar sesión. Intenta de nuevo.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> _ejecutar(Future<UsuarioSesion> Function() accion) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await accion();
      return true;
    } on AuthException catch (error) {
      _error = error.mensaje;
      return false;
    } catch (_) {
      _error = 'No se pudo completar la operación. Intenta de nuevo.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
