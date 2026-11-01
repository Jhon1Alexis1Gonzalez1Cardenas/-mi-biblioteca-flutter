import 'package:flutter/material.dart';

import '../models/libro.dart';
import '../theme/app_theme.dart';

/// Selector de estado de lectura usado en los formularios de agregar y editar.
class SelectorEstado extends StatelessWidget {
  const SelectorEstado({
    super.key,
    required this.estado,
    required this.seleccionado,
    required this.onTap,
  });

  final String estado;
  final bool seleccionado;
  final VoidCallback onTap;

  static Color colorSolido(String estado) => switch (estado) {
        Libro.estadoLeyendo => AppTheme.statusReadingSolid,
        Libro.estadoTerminado => AppTheme.statusFinishedSolid,
        _ => AppTheme.statusPendingSolid,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorSolido(estado);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado ? color : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? color : const Color(0xFF79747E),
          ),
        ),
        child: Text(
          estado,
          style: TextStyle(
            color: seleccionado ? Colors.white : AppTheme.textMuted,
            fontSize: 13,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
