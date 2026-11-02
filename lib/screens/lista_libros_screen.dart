import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/libros_provider.dart';
import '../models/libro.dart';
import '../theme/app_theme.dart';
import '../widgets/buscador_libros.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/libro_card.dart';
import 'agregar_libro_screen.dart';
import 'detalle_libro_screen.dart';

class ListaLibrosScreen extends StatefulWidget {
  const ListaLibrosScreen({super.key});

  @override
  State<ListaLibrosScreen> createState() => _ListaLibrosScreenState();
}

class _ListaLibrosScreenState extends State<ListaLibrosScreen> {
  final _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibrosProvider>().cargarLibros();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _limpiarFiltros() {
    _busquedaController.clear();
    context.read<LibrosProvider>().limpiarFiltros();
  }

  Future<void> _abrirAgregarLibro() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AgregarLibroScreen()),
    );
  }

  Future<void> _abrirDetalle(Libro libro) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalleLibroScreen(libro: libro)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibrosProvider>();
    final mostrarFiltros = !provider.cargando &&
        provider.error == null &&
        !provider.estaVacia;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Encabezado(onAgregar: _abrirAgregarLibro),
            if (mostrarFiltros)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: BuscadorLibros(
                  controller: _busquedaController,
                  onBuscar: provider.buscar,
                  filtroEstado: provider.filtroEstado,
                  onFiltrar: provider.filtrarPorEstado,
                ),
              ),
            Expanded(
              child: _Contenido(
                provider: provider,
                onAgregar: _abrirAgregarLibro,
                onAbrirLibro: _abrirDetalle,
                onLimpiarFiltros: _limpiarFiltros,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.onAgregar});

  final VoidCallback onAgregar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Biblioteca',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu colección, siempre en orden',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Material(
            color: AppTheme.primaryColor,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onAgregar,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.provider,
    required this.onAgregar,
    required this.onAbrirLibro,
    required this.onLimpiarFiltros,
  });

  final LibrosProvider provider;
  final VoidCallback onAgregar;
  final void Function(Libro libro) onAbrirLibro;
  final VoidCallback onLimpiarFiltros;

  @override
  Widget build(BuildContext context) {
    if (provider.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return EstadoVacio(
        titulo: 'Algo salió mal',
        mensaje: provider.error!,
        accion: ElevatedButton(
          onPressed: () => context.read<LibrosProvider>().cargarLibros(),
          child: const Text('Reintentar'),
        ),
      );
    }

    if (provider.estaVacia) {
      return EstadoVacio(
        titulo: 'Tu biblioteca está vacía',
        mensaje: 'Agrega tu primer libro y empieza a registrar tu lectura.',
        accion: ElevatedButton(
          onPressed: onAgregar,
          child: const Text('Agregar libro'),
        ),
      );
    }

    if (provider.sinResultados) {
      return EstadoVacio(
        titulo: 'Sin resultados',
        mensaje: 'No encontramos libros con esa búsqueda o filtro. '
            'Prueba con otras palabras.',
        accion: ElevatedButton(
          onPressed: onLimpiarFiltros,
          child: const Text('Limpiar filtros'),
        ),
      );
    }

    final resultados = provider.librosFiltrados;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Todos los libros',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${resultados.length} '
                '${resultados.length == 1 ? 'libro' : 'libros'}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ...resultados.map(
          (libro) => LibroCard(
            libro: libro,
            onTap: () => onAbrirLibro(libro),
          ),
        ),
      ],
    );
  }
}
