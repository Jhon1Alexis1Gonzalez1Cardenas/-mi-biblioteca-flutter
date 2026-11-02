import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Título con flecha de volver, usado en Login y Registro.
class EncabezadoPantalla extends StatelessWidget {
  const EncabezadoPantalla({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.onVolver,
  });

  final String titulo;
  final String subtitulo;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppTheme.surfaceWhite,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onVolver,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back,
                color: AppTheme.textDark,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Etiqueta en negrita sobre un campo de texto.
class EtiquetaCampo extends StatelessWidget {
  const EtiquetaCampo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
