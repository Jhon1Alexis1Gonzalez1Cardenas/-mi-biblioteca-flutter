import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/libros_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/libro_card.dart';
import 'agregar_libro_screen.dart';

class ListaLibrosScreen extends StatefulWidget {
  const ListaLibrosScreen({super.key});

  @override
  State<ListaLibrosScreen> createState() => _ListaLibrosScreenState();
}

class _ListaLibrosScreenState extends State<ListaLibrosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibrosProvider>().cargarLibros();
    });
  }

  Future<void> _abrirAgregarLibro() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AgregarLibroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibrosProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Encabezado(onAgregar: _abrirAgregarLibro),
            Expanded(
              child: _Contenido(
                provider: provider,
                onAgregar: _abrirAgregarLibro,
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
  const _Contenido({required this.provider, required this.onAgregar});

  final LibrosProvider provider;
  final VoidCallback onAgregar;

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
                '${provider.libros.length} '
                '${provider.libros.length == 1 ? 'libro' : 'libros'}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ...provider.libros.map((libro) => LibroCard(libro: libro)),
      ],
    );
  }
}
