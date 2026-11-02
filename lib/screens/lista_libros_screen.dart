import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/libros_provider.dart';
import '../models/libro.dart';
import '../theme/app_theme.dart';
import '../widgets/buscador_libros.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/libro_card.dart';
import 'agregar_libro_screen.dart';
import 'chat_screen.dart';
import 'detalle_libro_screen.dart';
import 'login_screen.dart';

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

  Future<void> _abrirChat() async {
    final auth = context.read<AuthProvider>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          nombreUsuario: _nombreDesdeCorreo(auth.usuario?.correo),
        ),
      ),
    );
  }

  /// "ana.perez@correo.com" -> "Ana".
  String? _nombreDesdeCorreo(String? correo) {
    final local = correo?.split('@').first.trim() ?? '';
    if (local.isEmpty) return null;
    final nombre = local.split(RegExp(r'[._-]')).first;
    if (nombre.isEmpty) return null;
    return nombre[0].toUpperCase() + nombre.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibrosProvider>();
    final auth = context.watch<AuthProvider>();
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
                paddingInferior: auth.autenticado ? 96 : 24,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: auth.autenticado
          ? FloatingActionButton(
              onPressed: _abrirChat,
              tooltip: 'Abrir asistente IA',
              backgroundColor: AppTheme.primaryColor,
              child: const _IconoIA(),
            )
          : null,
    );
  }
}

/// Icono del botón flotante: burbuja de chat con las letras "IA".
class _IconoIA extends StatelessWidget {
  const _IconoIA();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.chat_bubble, color: Colors.white, size: 26),
          Text(
            'IA',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BotonSesion(),
          const SizedBox(height: 14),
          Row(
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
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
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
        ],
      ),
    );
  }
}

/// Muestra "Iniciar sesión" sin sesión, o el avatar con el menú de cuenta.
class _BotonSesion extends StatelessWidget {
  const _BotonSesion();

  Future<void> _cerrarSesion(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final exito = await auth.cerrarSesion();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exito ? 'Sesión cerrada' : auth.error ?? 'No se pudo cerrar sesión',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.autenticado) {
      return Material(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final correo = auth.usuario!.correo;

    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      color: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (valor) {
        if (valor == 'cerrar') _cerrarSesion(context);
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            correo,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 13,
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'cerrar',
          child: Text(
            'Cerrar sesión',
            style: TextStyle(color: AppTheme.dangerText, fontSize: 14),
          ),
        ),
      ],
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppTheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          auth.usuario!.inicial,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    this.paddingInferior = 24,
  });

  final LibrosProvider provider;
  final VoidCallback onAgregar;
  final void Function(Libro libro) onAbrirLibro;
  final VoidCallback onLimpiarFiltros;

  /// Espacio extra al final para que el botón flotante no tape contenido.
  final double paddingInferior;

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
      padding: EdgeInsets.fromLTRB(20, 4, 20, paddingInferior),
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
