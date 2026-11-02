import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_biblioteca/providers/auth_provider.dart';
import 'package:mi_biblioteca/services/auth_service.dart';

import 'helpers/auth_service_falso.dart';

void main() {
  late AuthServiceFalso servicio;
  late AuthProvider provider;

  setUp(() {
    servicio = AuthServiceFalso();
    provider = AuthProvider(service: servicio);
  });

  tearDown(() {
    provider.dispose();
    servicio.cerrar();
  });

  test('Inicia sesión y guarda el usuario', () async {
    final exito = await provider.iniciarSesion(
      correo: 'ana@correo.com',
      contrasena: 'lectura123',
    );

    expect(exito, isTrue);
    expect(provider.autenticado, isTrue);
    expect(provider.usuario?.correo, 'ana@correo.com');
    expect(provider.cargando, isFalse);
    expect(servicio.ultimoCorreo, 'ana@correo.com');
    expect(servicio.ultimaContrasena, 'lectura123');
  });

  test('Traduce el error de credenciales incorrectas', () async {
    servicio.errorAlIniciar = const AuthException(
      'Correo o contraseña incorrectos.',
    );

    final exito = await provider.iniciarSesion(
      correo: 'ana@correo.com',
      contrasena: 'incorrecta',
    );

    expect(exito, isFalse);
    expect(provider.autenticado, isFalse);
    expect(provider.error, 'Correo o contraseña incorrectos.');
    expect(provider.cargando, isFalse);
  });

  test('Registra una cuenta nueva', () async {
    final exito = await provider.registrar(
      correo: 'lucia@correo.com',
      contrasena: 'lectura2026',
    );

    expect(exito, isTrue);
    expect(provider.autenticado, isTrue);
    expect(provider.usuario?.correo, 'lucia@correo.com');
  });

  test('Muestra el error cuando el correo ya está registrado', () async {
    servicio.errorAlRegistrar = const AuthException(
      'Este correo ya está registrado.',
    );

    final exito = await provider.registrar(
      correo: 'ana@correo.com',
      contrasena: 'lectura2026',
    );

    expect(exito, isFalse);
    expect(provider.error, 'Este correo ya está registrado.');
  });

  test('Cierra la sesión', () async {
    await provider.iniciarSesion(
      correo: 'ana@correo.com',
      contrasena: 'lectura123',
    );
    expect(provider.autenticado, isTrue);

    final exito = await provider.cerrarSesion();

    expect(exito, isTrue);
    expect(provider.autenticado, isFalse);
    expect(provider.usuario, isNull);
    expect(servicio.vecesCerrada, 1);
  });

  test('Escucha los cambios de sesión de authStateChanges', () async {
    servicio.emitir(
      const UsuarioSesion(uid: 'uid-9', correo: 'alexis@correo.com'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.autenticado, isTrue);
    expect(provider.usuario?.correo, 'alexis@correo.com');

    servicio.emitir(null);
    await Future<void>.delayed(Duration.zero);

    expect(provider.autenticado, isFalse);
  });

  test('El avatar usa la inicial del correo', () {
    const usuario = UsuarioSesion(uid: '1', correo: 'ana@correo.com');
    expect(usuario.inicial, 'A');
  });

  test('Traduce los códigos de FirebaseAuth a español', () {
    String mensaje(String codigo) =>
        mensajeParaErrorDeFirebase(FirebaseAuthException(code: codigo));

    expect(
      mensaje('wrong-password'),
      'Correo o contraseña incorrectos.',
    );
    expect(
      mensaje('email-already-in-use'),
      'Este correo ya está registrado.',
    );
    expect(
      mensaje('network-request-failed'),
      'Sin conexión. Revisa tu red e intenta de nuevo.',
    );
    expect(
      mensaje('codigo-desconocido'),
      'No se pudo completar la operación. Intenta de nuevo.',
    );
  });
}
