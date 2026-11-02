import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/libro.dart';
import '../providers/libros_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/estado_lectura_chip.dart';
import '../widgets/portada_libro.dart';
import 'editar_libro_screen.dart';

class DetalleLibroScreen extends StatelessWidget {
  const DetalleLibroScreen({super.key, required this.libro});

  final Libro libro;

  Future<void> _editar(BuildContext context, Libro actual) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditarLibroScreen(libro: actual)));
  }

  Future<void> _confirmarEliminar(BuildContext context, Libro actual) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar libro?'),
        content: Text(
          'Se eliminará «${actual.titulo}» de tu biblioteca. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerText),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !context.mounted) return;

    final id = actual.id;
    if (id == null) return;

    final eliminado = await context.read<LibrosProvider>().eliminarLibro(id);
    if (!context.mounted) return;

    if (eliminado) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Libro eliminado')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar el libro. Intenta de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actual =
        context.watch<LibrosProvider>().buscarPorId(libro.id ?? -1) ?? libro;
    final progreso = actual.progresoLectura;
    final porcentaje = actual.porcentajeLectura;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Row(
              children: [
                Material(
                  color: AppTheme.surfaceWhite,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
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
                const Expanded(
                  child: Text(
                    'Detalle del libro',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Material(
                  color: AppTheme.primaryColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _editar(context, actual),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Tarjeta(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PortadaLibro(
                    titulo: actual.titulo,
                    ancho: 84,
                    alto: 110,
                    tamanoTexto: 12,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: EstadoLecturaChip(
                            estado: actual.estadoLectura,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          actual.titulo,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          actual.autor,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Tarjeta(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Progreso de lectura',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 8,
                      backgroundColor: AppTheme.primaryContainer,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Avanza a tu ritmo. Puedes actualizar el estado al editar.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Tarjeta(
                    child: _Dato(
                      icono: Icons.bar_chart,
                      etiqueta: 'GÉNERO',
                      valor: actual.genero.trim().isEmpty
                          ? 'Sin género'
                          : actual.genero,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Tarjeta(
                    child: _Dato(
                      icono: Icons.calendar_today_outlined,
                      etiqueta: 'PUBLICACIÓN',
                      valor: actual.anioPublicacion > 0
                          ? '${actual.anioPublicacion}'
                          : 'Sin dato',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (actual.estadoLectura != Libro.estadoTerminado)
              _Tarjeta(
                color: AppTheme.primaryContainer.withValues(alpha: 0.6),
                onTap: () => _editar(context, actual),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Terminaste este libro?',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Márcalo como terminado desde la edición.',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _editar(context, actual),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar libro'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _confirmarEliminar(context, actual),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar libro'),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.dangerBg,
                foregroundColor: AppTheme.dangerText,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child, this.color, this.onTap});

  final Widget child;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final contenido = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );

    if (onTap == null) return contenido;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: contenido,
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 8),
        Text(
          etiqueta,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
