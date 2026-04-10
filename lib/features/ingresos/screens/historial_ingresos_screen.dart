import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/app_user.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/sic_widgets.dart';
import '../models/ingreso_model.dart';
import '../services/ingreso_service.dart';

final _todosIngresosProvider = StreamProvider<List<IngresoModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;

  // Si es miembro solo trae sus propios ingresos
  if (user?.rol == UserRole.miembro) {
    return ref.watch(ingresoServiceProvider).streamPorMiembro(user!.uid);
  }

  // Si es staff trae todos
  return ref.watch(ingresoServiceProvider).streamTodos();
});

class HistorialIngresosScreen extends ConsumerStatefulWidget {
  const HistorialIngresosScreen({super.key});

  @override
  ConsumerState<HistorialIngresosScreen> createState() =>
      _HistorialIngresosScreenState();
}

class _HistorialIngresosScreenState
    extends ConsumerState<HistorialIngresosScreen> {
  TipoIngreso? _filtroTipo;
  DateTime? _desde;
  DateTime? _hasta;

  static const _iconos = {
    'diezmo':   (Icons.volunteer_activism,       AppColors.gold),
    'ofrenda':  (Icons.favorite_outline,         AppColors.green),
    'donacion': (Icons.card_giftcard_outlined,   AppColors.blue),
    'primicia': (Icons.star_outline_rounded,     AppColors.orange),
    'misiones': (Icons.flight_outlined,          AppColors.teal),
  };

  // ── Filtrado en el cliente ────────────────────────────
  List<IngresoModel> _aplicarFiltros(List<IngresoModel> todos) {
    return todos.where((i) {
      if (_filtroTipo != null && i.tipo != _filtroTipo) return false;
      if (_desde != null) {
        final desdeInicio =
            DateTime(_desde!.year, _desde!.month, _desde!.day, 0, 0, 0);
        if (i.fecha.isBefore(desdeInicio)) return false;
      }
      if (_hasta != null) {
        final hastaFin =
            DateTime(_hasta!.year, _hasta!.month, _hasta!.day, 23, 59, 59);
        if (i.fecha.isAfter(hastaFin)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(_todosIngresosProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Ingresos',
            style: TextStyle(color: AppColors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.gold),
            onPressed: () => context.go(AppRoutes.ingresoNuevo),
          ),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (todos) {
          final filtrados = _aplicarFiltros(todos);
          return Column(children: [
            _buildKPIs(todos, filtrados),
            _buildFiltros(),
            _buildDateRange(),
            Expanded(
              child: filtrados.isEmpty
                  ? SICEmptyState(
                      emoji: '💰',
                      title: 'Sin ingresos en este filtro',
                      subtitle:
                          'Intenta cambiar el tipo o el rango de fecha',
                      action: ElevatedButton.icon(
                        onPressed: () => setState(() {
                          _filtroTipo = null;
                          _desde = null;
                          _hasta = null;
                        }),
                        icon: const Icon(Icons.clear_rounded),
                        label: const Text('Limpiar filtros'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: filtrados.length,
                      itemBuilder: (ctx, i) =>
                          _buildIngresoTile(filtrados[i]),
                    ),
            ),
          ]);
        },
      ),
    );
  }

  // ── KPIs ──────────────────────────────────────────────
  Widget _buildKPIs(
      List<IngresoModel> todos, List<IngresoModel> filtrados) {
    final totalTodos = todos.fold(0.0, (s, i) => s + i.monto);
    final totalFiltrado = filtrados.fold(0.0, (s, i) => s + i.monto);
    return Container(
      padding: const EdgeInsets.all(14),
      color: AppColors.dark,
      child: Row(children: [
        Expanded(
            child: _miniKpi('TOTAL',
                CurrencyUtils.formatShort(totalTodos), AppColors.gold)),
        const SizedBox(width: 12),
        Expanded(
            child: _miniKpi(
                'REGISTROS', '${todos.length}', AppColors.greenLight)),
        const SizedBox(width: 12),
        Expanded(
            child: _miniKpi('FILTRADO',
                CurrencyUtils.formatShort(totalFiltrado), AppColors.goldLight)),
      ]),
    );
  }

  Widget _miniKpi(String label, String value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.textMutedLight)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      );

  // ── Filtro por tipo ───────────────────────────────────
  Widget _buildFiltros() {
    return Container(
      height: 46,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          // Botón "Todos"
          _chipFiltro(
            label: 'Todos',
            isSelected: _filtroTipo == null,
            onTap: () => setState(() => _filtroTipo = null),
          ),
          ...TipoIngreso.values.map((tipo) => _chipFiltro(
                label: tipo.label,
                isSelected: _filtroTipo == tipo,
                onTap: () => setState(() => _filtroTipo = tipo),
              )),
        ],
      ),
    );
  }

  Widget _chipFiltro({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.borderLight,
              width: 1.5),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  // ── Filtro por rango de fecha ─────────────────────────
  Widget _buildDateRange() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(children: [
        const Icon(Icons.calendar_today_rounded,
            size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        _datePicker(
          label: _desde != null ? SICDateUtils.format(_desde!) : 'Desde',
          onPick: (d) => setState(() => _desde = d),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child:
              Text('—', style: TextStyle(color: AppColors.textMuted)),
        ),
        _datePicker(
          label: _hasta != null ? SICDateUtils.format(_hasta!) : 'Hasta',
          onPick: (d) => setState(() => _hasta = d),
        ),
        const Spacer(),
        if (_desde != null || _hasta != null)
          GestureDetector(
            onTap: () => setState(() {
              _desde = null;
              _hasta = null;
            }),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.redBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Limpiar',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _datePicker({
    required String label,
    required Function(DateTime) onPick,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme:
                  const ColorScheme.light(primary: AppColors.gold),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ),
    );
  }

  // ── Tile de ingreso ───────────────────────────────────
  Widget _buildIngresoTile(IngresoModel ingreso) {
    final ico = _iconos[ingreso.tipo.value] ??
        (Icons.attach_money_rounded, AppColors.gold);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (ico.$2 as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(ico.$1 as IconData,
              color: ico.$2 as Color, size: 20),
        ),
        title: Text(
          ingreso.memberName,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        subtitle: Text(
          '${ingreso.tipo.label} · ${SICDateUtils.format(ingreso.fecha)} · ${ingreso.metodo.label}',
          style: const TextStyle(
              fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${CurrencyUtils.format(ingreso.monto)}',
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.green),
            ),
            const SICStatusChip(
                label: 'Registrado',
                bg: Color(0xFFDCFCE7),
                fg: Color(0xFF15803D)),
          ],
        ),
        onTap: () => context.go('/ingresos/editar/${ingreso.id}'),
      ),
    );
  }
}