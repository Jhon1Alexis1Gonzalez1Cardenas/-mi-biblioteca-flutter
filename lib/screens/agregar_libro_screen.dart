import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/libro.dart';
import '../providers/libros_provider.dart';
import '../theme/app_theme.dart';

class AgregarLibroScreen extends StatefulWidget {
  const AgregarLibroScreen({super.key});

  @override
  State<AgregarLibroScreen> createState() => _AgregarLibroScreenState();
}

class _AgregarLibroScreenState extends State<AgregarLibroScreen> {
  static const List<String> _generos = [
    'Novela',
    'Cuento',
    'Ensayo',
    'Poesía',
    'Ciencia ficción',
    'Fantasía',
    'Historia',
    'Biografía',
    'Otro',
  ];

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _anioController = TextEditingController();

  String? _genero;
  String _estadoLectura = Libro.estadoPendiente;
  bool _guardando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _anioController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final libro = Libro(
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      genero: _genero ?? '',
      anioPublicacion: int.tryParse(_anioController.text.trim()) ??
          DateTime.now().year,
      estadoLectura: _estadoLectura,
    );

    final guardado = await context.read<LibrosProvider>().agregarLibro(libro);
    if (!mounted) return;

    if (guardado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro agregado a tu biblioteca')),
      );
      Navigator.of(context).pop();
    } else {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el libro. Intenta de nuevo.'),
        ),
      );
    }
  }

  String? _validarAnio(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null;
    final anio = int.tryParse(texto);
    if (anio == null) return 'Escribe un año válido';
    if (anio < 1 || anio > DateTime.now().year) {
      return 'Entre 1 y ${DateTime.now().year}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _Encabezado(onVolver: () => Navigator.of(context).pop()),
              const SizedBox(height: 20),
              const _Aviso(),
              const SizedBox(height: 24),
              const _Etiqueta('Título'),
              TextFormField(
                controller: _tituloController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Escribe el título',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: (valor) =>
                    (valor == null || valor.trim().isEmpty)
                        ? 'El título es obligatorio'
                        : null,
              ),
              const SizedBox(height: 16),
              const _Etiqueta('Autor'),
              TextFormField(
                controller: _autorController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Nombre del autor o autora',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (valor) =>
                    (valor == null || valor.trim().isEmpty)
                        ? 'El autor es obligatorio'
                        : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Etiqueta('Género'),
                        DropdownButtonFormField<String>(
                          initialValue: _genero,
                          isExpanded: true,
                          hint: const Text('Seleccionar'),
                          decoration: const InputDecoration(),
                          items: _generos
                              .map(
                                (genero) => DropdownMenuItem(
                                  value: genero,
                                  child: Text(genero),
                                ),
                              )
                              .toList(),
                          onChanged: (valor) => setState(() => _genero = valor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Etiqueta('Año'),
                        TextFormField(
                          controller: _anioController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: const InputDecoration(
                            hintText: '2026',
                          ),
                          validator: _validarAnio,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Etiqueta('Estado de lectura'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Libro.estados
                    .map(
                      (estado) => _SelectorEstado(
                        estado: estado,
                        seleccionado: estado == _estadoLectura,
                        onTap: () => setState(() => _estadoLectura = estado),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_guardando ? 'Guardando...' : 'Guardar libro'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed:
                    _guardando ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Los datos se guardarán localmente en este dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.onVolver});

  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppTheme.surfaceWhite,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onVolver,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back, color: AppTheme.textDark, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agregar libro',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Completa los datos básicos',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
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

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelectorEstado extends StatelessWidget {
  const _SelectorEstado({
    required this.estado,
    required this.seleccionado,
    required this.onTap,
  });

  final String estado;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = switch (estado) {
      Libro.estadoLeyendo => (AppTheme.statusReadingBg, AppTheme.statusReadingText),
      Libro.estadoTerminado => (AppTheme.statusFinishedBg, AppTheme.statusFinishedText),
      _ => (AppTheme.statusPendingBg, AppTheme.statusPendingText),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado ? colores.$1 : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? colores.$2 : const Color(0xFF79747E),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Text(
          estado,
          style: TextStyle(
            color: seleccionado ? colores.$2 : AppTheme.textMuted,
            fontSize: 13,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
