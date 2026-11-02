import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validaciones.dart';
import '../widgets/campo_contrasena.dart';
import '../widgets/encabezado_pantalla.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmacionController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmacionController.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final exito = await provider.registrar(
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text,
    );
    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Sesión iniciada.')),
      );
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    }
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
                titulo: 'Crear cuenta',
                subtitulo: 'Regístrate para empezar a usar Mi Biblioteca',
                onVolver: () =>
                    Navigator.of(context).popUntil((ruta) => ruta.isFirst),
              ),
              const SizedBox(height: 28),
              const EtiquetaCampo('Correo electrónico'),
              TextFormField(
                controller: _correoController,
                enabled: !auth.cargando,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'tu@correo.com',
                ),
                validator: validarCorreo,
              ),
              const SizedBox(height: 16),
              const EtiquetaCampo('Contraseña'),
              CampoContrasena(
                controller: _contrasenaController,
                hintText: 'Mínimo 6 caracteres',
                habilitado: !auth.cargando,
                textInputAction: TextInputAction.next,
                validator: validarContrasena,
              ),
              const SizedBox(height: 16),
              const EtiquetaCampo('Confirmar contraseña'),
              CampoContrasena(
                controller: _confirmacionController,
                hintText: 'Repite tu contraseña',
                habilitado: !auth.cargando,
                textInputAction: TextInputAction.done,
                validator: (valor) =>
                    validarConfirmacion(valor, _contrasenaController.text),
                onFieldSubmitted: (_) => _crearCuenta(),
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
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'La contraseña debe tener mínimo 6 caracteres.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: auth.cargando ? null : _crearCuenta,
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
                    : const Text('Crear cuenta'),
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta?',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          auth.cargando ? null : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
