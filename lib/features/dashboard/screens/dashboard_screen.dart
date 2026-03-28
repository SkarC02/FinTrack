import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sic_app/features/ingresos/models/ingreso_model.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user         = ref.watch(currentUserProvider).valueOrNull;
    final resumenAsync = ref.watch(dashboardResumenProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.cream,
      appBar: _buildAppBar(context, ref, user?.nombreCompleto ?? ''),
      body: resumenAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline,
                  color: AppColors.redLight, size: 48),
              const SizedBox(height: 12),
              Text('Error al cargar datos:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.invalidate(dashboardResumenProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ]),
          ),
        ),
        data: (resumen) => RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async {
            ref.invalidate(dashboardResumenProvider);
            ref.invalidate(dashboardGraficaProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            children: [
              _buildKPIs(resumen),
              _buildAlerts(resumen),
              const SizedBox(height: 10),
              _buildBarChart(ref),
              const SizedBox(height: 10),
              _buildDonutChart(resumen),
              const SizedBox(height: 10),
              _buildUltimasTransacciones(context, resumen),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, String nombre) {
    final mes = DateFormat('MMM yyyy', 'es').format(DateTime.now());
    return AppBar(
      backgroundColor: AppColors.dark,
      automaticallyImplyLeading: false,
      title: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.church_rounded,
              color: AppColors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Dashboard',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight)),
          Text('FinTrack',
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.goldLight,
                  letterSpacing: 1.2)),
        ]),
      ]),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Text(mes,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w700)),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: () => context.go('${AppRoutes.ingresos}/nuevo'),
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gold,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(34, 34),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIs(DashboardResumen r) {
    final fmt = NumberFormat('#,##0.00');
    return GridView.count(
      crossAxisCount:   2,
      shrinkWrap:       true,
      physics:          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing:  8,
      childAspectRatio: 1.5,
      children: [
        _KpiCard(
          label:   'Ingresos',
          value:   'L ${fmt.format(r.totalIngresos)}',
          subtitle: 'Este mes',
          icon:    Icons.trending_up_rounded,
          color:   AppColors.green,
        ),
        _KpiCard(
          label:   'Gastos',
          value:   'L ${fmt.format(r.totalGastos)}',
          subtitle: 'Este mes',
          icon:    Icons.trending_down_rounded,
          color:   AppColors.redLight,
        ),
        _KpiCard(
          label:   'Saldo',
          value:   'L ${fmt.format(r.saldo)}',
          subtitle: 'Disponible',
          icon:    Icons.account_balance_wallet_outlined,
          color:   r.saldo >= 0 ? AppColors.gold : AppColors.redLight,
        ),
        _KpiCard(
          label:   'Diezmadores',
          value:   '${r.diezmadores} / ${r.totalMiembros}',
          subtitle: 'miembros activos',
          icon:    Icons.people_outline_rounded,
          color:   AppColors.blue,
        ),
      ],
    );
  }

  Widget _buildAlerts(DashboardResumen r) {
    if (r.totalIngresos == 0) return const SizedBox.shrink();
    if (r.totalGastos <= r.totalIngresos * 0.8) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        const Color(0xFFFFF8E1),
        border:       Border.all(color: const Color(0xFFFFD54F)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded,
            color: Color(0xFF6D4C00), size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Los gastos representan más del 80% de los ingresos del mes.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6D4C00)),
          ),
        ),
      ]),
    );
  }

  Widget _buildBarChart(WidgetRef ref) {
    final graficaAsync = ref.watch(dashboardGraficaProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Ingresos vs Gastos',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const Spacer(),
          _legendDot(AppColors.green,  'Ingresos'),
          const SizedBox(width: 10),
          _legendDot(AppColors.orange, 'Gastos'),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: graficaAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2),
            ),
            error: (e, _) => Center(
              child: Text('Sin datos de gráfica',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
            data: (datos) {
              final hayDatos = datos.any((d) =>
                  (d['ingresos'] as double) > 0 ||
                  (d['gastos'] as double) > 0);

              if (!hayDatos) {
                return const Center(
                  child: Text('Sin movimientos en los últimos 6 meses',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                );
              }

              return BarChart(BarChartData(
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= datos.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(datos[idx]['label'] as String,
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted)),
                        );
                      },
                    ),
                  ),
                  leftTitles:  AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles:   AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData:   FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups:  datos.asMap().entries.map((e) {
                  final d   = e.value;
                  final ing = (d['ingresos'] as double);
                  final gas = (d['gastos']   as double);
                  final max = ing > gas ? ing : gas;
                  final div = max > 0 ? max : 1;
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY:   ing / div * 10,
                      color: AppColors.green.withOpacity(0.85),
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY:   gas / div * 10,
                      color: AppColors.orange.withOpacity(0.85),
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ]);
                }).toList(),
              ));
            },
          ),
        ),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) => Row(children: [
    Container(
      width: 7, height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
    const SizedBox(width: 4),
    Text(label,
        style: const TextStyle(
            fontSize: 10, color: AppColors.textMuted)),
  ]);

  Widget _buildDonutChart(DashboardResumen r) {
    if (r.ingresosPorTipo.isEmpty) return const SizedBox.shrink();

    const colors = [
      AppColors.gold, AppColors.green, AppColors.blue,
      AppColors.orange, AppColors.purple,
    ];
    const labels = {
      'diezmo':   'Diezmos',
      'ofrenda':  'Ofrendas',
      'donacion': 'Donaciones',
      'primicia': 'Primicias',
      'misiones': 'Misiones',
    };

    final entries = r.ingresosPorTipo.entries.toList();
    final total   = r.totalIngresos;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Distribución Ingresos',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 14),
        Row(children: [
          SizedBox(
            width: 90, height: 90,
            child: PieChart(PieChartData(
              sectionsSpace:     2,
              centerSpaceRadius: 26,
              sections: entries.asMap().entries.map((e) {
                final pct = total > 0 ? e.value.value / total : 0;
                return PieChartSectionData(
                  color:  colors[e.key % colors.length],
                  value:  e.value.value,
                  title:  '${(pct * 100).toStringAsFixed(0)}%',
                  radius: 30,
                  titleStyle: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                );
              }).toList(),
            )),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: entries.asMap().entries.map((e) {
                final pct   = total > 0 ? e.value.value / total * 100 : 0;
                final label = labels[e.value.key] ?? e.value.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textDark)),
                    ),
                    Text('${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted)),
                  ]),
                );
              }).toList(),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildUltimasTransacciones(
      BuildContext context, DashboardResumen r) {
    final fmt = DateFormat('dd/MM/yy');
    final fmtM = NumberFormat('#,##0.00');

    final todas = <Map<String, dynamic>>[];

    for (final i in r.ultimasTransaccionesIngreso) {
      todas.add({
        'fecha':      i.fecha,
        'titulo':     i.tipo.label,
        'sub':        '${fmt.format(i.fecha)} · ${i.memberName}',
        'monto':      '+L ${fmtM.format(i.monto)}',
        'isPositive': true,
        'color':      AppColors.green,
        'bg':         AppColors.greenBg,
        'icon':       Icons.arrow_downward_rounded,
      });
    }

    for (final g in r.ultimasTransaccionesGasto) {
      todas.add({
        'fecha':      g.fecha,
        'titulo':     g.descripcion,
        'sub':        '${fmt.format(g.fecha)} · ${g.proveedor}',
        'monto':      '-L ${fmtM.format(g.monto)}',
        'isPositive': false,
        'color':      AppColors.redLight,
        'bg':         AppColors.redBg,
        'icon':       Icons.arrow_upward_rounded,
      });
    }

    todas.sort((a, b) =>
        (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));

    if (todas.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
          child: Row(children: [
            Text('Últimas Transacciones',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(AppRoutes.ingresos),
              child: const Text('Ver más',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.gold)),
            ),
          ]),
        ),
        ...todas.take(6).map((t) => Column(children: [
          const Divider(height: 1, color: AppColors.borderLight),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color:        t['bg'] as Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(t['icon'] as IconData,
                  color: t['color'] as Color, size: 18),
            ),
            title: Text(t['titulo'] as String,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(t['sub'] as String,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
            trailing: Text(t['monto'] as String,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t['color'] as Color)),
          ),
        ])),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String  label;
  final String  value;
  final String  subtitle;
  final IconData icon;
  final Color   color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const Spacer(),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5)),
          ]),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color),
              maxLines:  1,
              overflow:  TextOverflow.ellipsis),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}