import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validaciones.dart';
import '../widgets/campo_contrasena.dart';
import '../widgets/encabezado_pantalla.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final exito = await provider.iniciarSesion(
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text,
    );
    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sesión iniciada')));
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    }
  }

  void _irARegistro() {
    context.read<AuthProvider>().limpiarError();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegistroScreen()));
  }

  void _volverALista() {
    context.read<AuthProvider>().limpiarError();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              EncabezadoPantalla(
                titulo: 'Iniciar sesión',
                subtitulo: 'Accede a tu biblioteca personal',
                onVolver: _volverALista,
              ),
              const SizedBox(height: 28),
              const Center(child: _IconoLibro()),
              const SizedBox(height: 28),
              const EtiquetaCampo('Correo electrónico'),
              TextFormField(
                controller: _correoController,
                enabled: !auth.cargando,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(hintText: 'tu@correo.com'),
                validator: validarCorreo,
              ),
              const SizedBox(height: 16),
              const EtiquetaCampo('Contraseña'),
              CampoContrasena(
                controller: _contrasenaController,
                hintText: 'Mínimo 6 caracteres',
                habilitado: !auth.cargando,
                textInputAction: TextInputAction.done,
                validator: validarContrasena,
                onFieldSubmitted: (_) => _iniciarSesion(),
              ),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(
                      color: AppTheme.dangerText,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: auth.cargando ? null : _iniciarSesion,
                child: auth.cargando
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Validando...'),
                        ],
                      )
                    : const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: auth.cargando ? null : _irARegistro,
                      child: const Text(
                        'Regístrate aquí',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Tu sesión se mantiene iniciada en este dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconoLibro extends StatelessWidget {
  const _IconoLibro();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.menu_book_outlined,
        size: 34,
        color: AppTheme.primaryColor,
      ),
    );
  }
}
