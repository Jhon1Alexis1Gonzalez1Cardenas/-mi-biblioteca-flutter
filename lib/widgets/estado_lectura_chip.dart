import 'package:flutter/material.dart';

import '../models/libro.dart';
import '../theme/app_theme.dart';

/// Chip de estado de lectura: Pendiente (gris), Leyendo (azul), Terminado (verde).
class EstadoLecturaChip extends StatelessWidget {
  const EstadoLecturaChip({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final colores = switch (estado) {
      Libro.estadoLeyendo => (AppTheme.statusReadingBg, AppTheme.statusReadingText),
      Libro.estadoTerminado => (AppTheme.statusFinishedBg, AppTheme.statusFinishedText),
      _ => (AppTheme.statusPendingBg, AppTheme.statusPendingText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colores.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: colores.$2,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
