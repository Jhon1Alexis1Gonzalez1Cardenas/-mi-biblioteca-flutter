import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/libro.dart';
import '../providers/libros_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/libro_formulario.dart';
import '../widgets/portada_libro.dart';

class EditarLibroScreen extends StatelessWidget {
  const EditarLibroScreen({super.key, required this.libro});

  final Libro libro;

  @override
  Widget build(BuildContext context) {
    return LibroFormulario(
      libroInicial: libro,
      tituloEncabezado: 'Editar libro',
      subtituloEncabezado: 'Actualiza los datos o el estado',
      textoGuardar: 'Guardar cambios',
      textoSecundario: 'Descartar cambios',
      notaPie: 'Al guardar, volverás al detalle del libro.',
      encabezadoExtra: _LibroEnEdicion(titulo: libro.titulo),
      onGuardar: (actualizado) =>
          context.read<LibrosProvider>().actualizarLibro(actualizado),
      alGuardarExitoso: (context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados')),
        );
        Navigator.of(context).pop(true);
      },
    );
  }
}

class _LibroEnEdicion extends StatelessWidget {
  const _LibroEnEdicion({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          PortadaLibro(titulo: titulo, ancho: 40, alto: 54, tamanoTexto: 8),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EDITANDO',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
