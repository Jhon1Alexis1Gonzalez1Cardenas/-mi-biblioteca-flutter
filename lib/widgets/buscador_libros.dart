import 'package:flutter/material.dart';

import '../models/libro.dart';
import '../theme/app_theme.dart';

/// Campo de búsqueda y chips de filtro por estado de lectura.
class BuscadorLibros extends StatelessWidget {
  const BuscadorLibros({
    super.key,
    required this.controller,
    required this.onBuscar,
    required this.filtroEstado,
    required this.onFiltrar,
  });

  final TextEditingController controller;
  final ValueChanged<String> onBuscar;

  /// null equivale al chip "Todos".
  final String? filtroEstado;
  final ValueChanged<String?> onFiltrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, valor, _) {
              return TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onChanged: onBuscar,
                decoration: InputDecoration(
                  hintText: 'Buscar por título o autor',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textMuted,
                  ),
                  suffixIcon: valor.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          icon: const Icon(
                            Icons.close,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () {
                            controller.clear();
                            onBuscar('');
                          },
                        ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ChipFiltro(
                key: const ValueKey('chip-filtro-Todos'),
                texto: 'Todos',
                seleccionado: filtroEstado == null,
                onTap: () => onFiltrar(null),
              ),
              for (final estado in Libro.estados) ...[
                const SizedBox(width: 6),
                _ChipFiltro(
                  key: ValueKey('chip-filtro-$estado'),
                  texto: estado,
                  seleccionado: filtroEstado == estado,
                  onTap: () => onFiltrar(estado),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    super.key,
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado ? AppTheme.primaryColor : AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: seleccionado
                  ? AppTheme.primaryColor
                  : const Color(0xFFD9D3E3),
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(
              color: seleccionado ? Colors.white : AppTheme.textMuted,
              fontSize: 12.5,
              fontWeight:
                  seleccionado ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
