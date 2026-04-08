// ═══════════════════════════════════════════════════════════════════════════
//  lib/features/gastos/screens/historial_gastos_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/sic_widgets.dart';
import '../models/gasto_model.dart';
import '../services/gasto_service.dart';

final gastosStreamProvider = StreamProvider<List<GastoModel>>(
  (ref) => ref.watch(gastoServiceProvider).streamMesActual(),
);

class HistorialGastosScreen extends ConsumerStatefulWidget {
  const HistorialGastosScreen({super.key});

  @override
  ConsumerState<HistorialGastosScreen> createState() =>
      _HistorialGastosScreenState();
}

class _HistorialGastosScreenState
    extends ConsumerState<HistorialGastosScreen> {
  String _filtroCategoria = '';

  static const _iconos = {
    'servicios': ('⚡', AppColors.blue),
    'mantenimiento': ('🔧', AppColors.redLight),
    'actividades': ('🎵', AppColors.greenLight),
    'personal': ('👤', AppColors.gold),
    'misiones': ('✈️', AppColors.teal),
  };

  @override
  Widget build(BuildContext context) {
    final gastosAsync = ref.watch(gastosStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text(
          'Gastos y Egresos',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.gold),
            onPressed: () => context.go(AppRoutes.gastoNuevo),
          ),
        ],
      ),
      body: Column(
        children: [
          gastosAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (gastos) => _buildKPIs(gastos),
          ),
          _buildFiltros(),
          Expanded(
            child: gastosAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (gastos) {
                final filtrados = _filtroCategoria.isEmpty
                    ? gastos
                    : gastos
                          .where((g) => g.categoria == _filtroCategoria)
                          .toList();

                if (filtrados.isEmpty) {
                  return SICEmptyState(
                    emoji: '📋',
                    title: 'Sin gastos registrados',
                    action: ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.gastoNuevo),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Agregar Gasto'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtrados.length,
                  itemBuilder: (ctx, i) => _buildGastoTile(filtrados[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs(List<GastoModel> gastos) {
    final total = gastos.fold(0.0, (s, g) => s + g.monto);
    final pendientes = gastos
        .where((g) => g.estado == 'pendiente')
        .fold(0.0, (s, g) => s + g.monto);

    return Container(
      padding: const EdgeInsets.all(14),
      color: AppColors.dark,
      child: Row(
        children: [
          Expanded(
            child: _miniKpi(
              'TOTAL GASTOS',
              CurrencyUtils.formatShort(total),
              AppColors.redLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _miniKpi(
              'EGRESOS',
              '${gastos.length}',
              AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _miniKpi(
              'PENDIENTES',
              CurrencyUtils.formatShort(pendientes),
              AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniKpi(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    final cats = ['', ...AppConstants.categoriasGasto];
    final labels = {
      '': 'Todos',
      'servicios': 'Servicios',
      'mantenimiento': 'Mantenim.',
      'actividades': 'Actividades',
      'personal': 'Personal',
      'misiones': 'Misiones',
    };

    return Container(
      height: 44,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: cats.map((c) {
          final isSelected = _filtroCategoria == c;

          return GestureDetector(
            onTap: () => setState(() => _filtroCategoria = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.redLight : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.redLight
                      : AppColors.borderLight,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                labels[c] ?? c,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGastoTile(GastoModel gasto) {
    final ico = _iconos[gasto.categoria] ?? ('📋', AppColors.textMuted);
    final isPagado = gasto.estado == 'pagado';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (ico.$2 as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              ico.$1 as String,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        title: Text(
          gasto.descripcion,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          '${AppConstants.categoriasGastoLabel[gasto.categoria] ?? gasto.categoria} · ${SICDateUtils.format(gasto.fecha)}${gasto.proveedor.isNotEmpty ? ' · ${gasto.proveedor}' : ''}',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-${CurrencyUtils.format(gasto.monto)}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.red,
              ),
            ),
            isPagado ? SICStatusChip.pagado() : SICStatusChip.pendiente(),
          ],
        ),
        onTap: () => context.go('/gastos/editar/${gasto.id}'),
      ),
    );
  }
}