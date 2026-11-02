import 'package:firebase_auth/firebase_auth.dart';

/// Sesión mínima que necesita la app (sin exponer tipos de Firebase).
class UsuarioSesion {
  const UsuarioSesion({required this.uid, required this.correo});

  final String uid;
  final String correo;

  String get inicial =>
      correo.trim().isEmpty ? '?' : correo.trim()[0].toUpperCase();
}

/// Error de autenticación con un mensaje listo para mostrar en la UI.
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato de autenticación para poder simularlo en las pruebas.
abstract class AuthService {
  Stream<UsuarioSesion?> get authStateChanges;

  UsuarioSesion? get usuarioActual;

  Future<UsuarioSesion> registrar({
    required String correo,
    required String contrasena,
  });

  Future<UsuarioSesion> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<void> cerrarSesion();
}

/// Único lugar de la app que habla con FirebaseAuth.
class FirebaseAuthService implements AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  Stream<UsuarioSesion?> get authStateChanges =>
      _auth.authStateChanges().map(_mapear);

  @override
  UsuarioSesion? get usuarioActual => _mapear(_auth.currentUser);

  @override
  Future<UsuarioSesion> registrar({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return _mapear(credencial.user)!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeParaErrorDeFirebase(error));
    } catch (_) {
      throw const AuthException(
        'No se pudo crear la cuenta. Revisa tu conexión e intenta de nuevo.',
      );
    }
  }

  @override
  Future<UsuarioSesion> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return _mapear(credencial.user)!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeParaErrorDeFirebase(error));
    } catch (_) {
      throw const AuthException(
        'No se pudo iniciar sesión. Revisa tu conexión e intenta de nuevo.',
      );
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(mensajeParaErrorDeFirebase(error));
    } catch (_) {
      throw const AuthException(
        'No se pudo cerrar sesión. Intenta de nuevo.',
      );
    }
  }

  UsuarioSesion? _mapear(User? user) {
    if (user == null) return null;
    return UsuarioSesion(uid: user.uid, correo: user.email ?? '');
  }
}

/// Traduce los códigos de FirebaseAuth a mensajes claros en español.
String mensajeParaErrorDeFirebase(FirebaseAuthException error) {
  return switch (error.code) {
    'invalid-email' => 'El correo no tiene un formato válido.',
    'user-disabled' => 'Esta cuenta está deshabilitada.',
    'user-not-found' => 'Correo o contraseña incorrectos.',
    'wrong-password' => 'Correo o contraseña incorrectos.',
    'invalid-credential' => 'Correo o contraseña incorrectos.',
    'email-already-in-use' => 'Este correo ya está registrado.',
    'weak-password' => 'La contraseña debe tener mínimo 6 caracteres.',
    'network-request-failed' =>
      'Sin conexión. Revisa tu red e intenta de nuevo.',
    'too-many-requests' =>
      'Demasiados intentos. Espera un momento e intenta de nuevo.',
    'operation-not-allowed' =>
      'El inicio de sesión con correo no está habilitado.',
    _ => 'No se pudo completar la operación. Intenta de nuevo.',
  };
}
