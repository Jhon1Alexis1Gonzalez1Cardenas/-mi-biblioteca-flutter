import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Portada generada a partir del título (la app no guarda imágenes).
class PortadaLibro extends StatelessWidget {
  const PortadaLibro({
    super.key,
    required this.titulo,
    this.ancho = 48,
    this.alto = 64,
    this.tamanoTexto = 9,
  });

  final String titulo;
  final double ancho;
  final double alto;
  final double tamanoTexto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: alto,
      padding: EdgeInsets.all(ancho * 0.12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(ancho * 0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: Text(
                titulo,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: tamanoTexto,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: ancho * 0.16,
              height: ancho * 0.16,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
