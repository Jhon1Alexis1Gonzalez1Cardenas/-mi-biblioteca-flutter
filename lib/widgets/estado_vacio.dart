import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.accion,
  });

  final String titulo;
  final String mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 44,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (accion != null) ...[
              const SizedBox(height: 24),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
