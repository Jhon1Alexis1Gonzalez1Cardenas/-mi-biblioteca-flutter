import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/libros_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/libro_formulario.dart';

class AgregarLibroScreen extends StatelessWidget {
  const AgregarLibroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LibroFormulario(
      tituloEncabezado: 'Agregar libro',
      subtituloEncabezado: 'Completa los datos básicos',
      textoGuardar: 'Guardar libro',
      textoSecundario: 'Cancelar',
      notaPie: 'Los datos se guardarán localmente en este dispositivo.',
      encabezadoExtra: const _Aviso(),
      onGuardar: (libro) => context.read<LibrosProvider>().agregarLibro(libro),
      alGuardarExitoso: (context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro agregado a tu biblioteca')),
        );
        Navigator.of(context).pop();
      },
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.library_add_outlined, color: AppTheme.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Añade un libro para empezar a registrar tu lectura.',
              style: TextStyle(color: AppTheme.textDark, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
