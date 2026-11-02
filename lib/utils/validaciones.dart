/// Validaciones compartidas por Login y Registro.
final RegExp _patronCorreo = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

String? validarCorreo(String? valor) {
  final correo = valor?.trim() ?? '';
  if (correo.isEmpty) return 'El correo es obligatorio';
  if (!_patronCorreo.hasMatch(correo)) return 'Escribe un correo válido';
  return null;
}

String? validarContrasena(String? valor) {
  final contrasena = valor ?? '';
  if (contrasena.isEmpty) return 'La contraseña es obligatoria';
  if (contrasena.length < 6) return 'Mínimo 6 caracteres';
  return null;
}

String? validarConfirmacion(String? valor, String contrasena) {
  if (valor == null || valor.isEmpty) return 'Confirma tu contraseña';
  if (valor != contrasena) return 'Las contraseñas no coinciden';
  return null;
}
