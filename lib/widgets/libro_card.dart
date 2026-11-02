import 'package:flutter/material.dart';

import '../models/libro.dart';
import '../theme/app_theme.dart';
import 'estado_lectura_chip.dart';
import 'portada_libro.dart';

class LibroCard extends StatelessWidget {
  const LibroCard({super.key, required this.libro, this.onTap});

  final Libro libro;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final detalle = libro.estadoLectura == Libro.estadoLeyendo
        ? '${libro.porcentajeLectura}%'
        : [
            if (libro.genero.trim().isNotEmpty) libro.genero.trim(),
            if (libro.anioPublicacion > 0) '${libro.anioPublicacion}',
          ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortadaLibro(titulo: libro.titulo),
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
                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 20),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
