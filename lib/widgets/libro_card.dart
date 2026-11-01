import 'package:flutter/material.dart';

import '../models/libro.dart';
import '../theme/app_theme.dart';
import 'estado_lectura_chip.dart';

class LibroCard extends StatelessWidget {
  const LibroCard({super.key, required this.libro});

  final Libro libro;

  @override
  Widget build(BuildContext context) {
    final detalle = [
      if (libro.genero.trim().isNotEmpty) libro.genero.trim(),
      if (libro.anioPublicacion > 0) '${libro.anioPublicacion}',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PortadaPlaceholder(titulo: libro.titulo),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  libro.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  libro.autor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    EstadoLecturaChip(estado: libro.estadoLectura),
                    const SizedBox(width: 8),
                    if (detalle.isNotEmpty)
                      Expanded(
                        child: Text(
                          detalle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortadaPlaceholder extends StatelessWidget {
  const _PortadaPlaceholder({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        titulo,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
