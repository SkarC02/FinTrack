import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../ingresos/models/ingreso_model.dart';
import '../../gastos/models/gasto_model.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final resumenAsync = ref.watch(
      StreamProvider<DashboardResumen>(
        (ref) => ref.watch(dashboardServiceProvider).streamResumenMes(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _buildAppBar(context, user?.nombreCompleto ?? ''),
      body: resumenAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (resumen) => RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async => ref.invalidate(dashboardServiceProvider),
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _buildKPIs(resumen),
              _buildAlerts(resumen),
              _buildBarChart(ref),
              _buildDonutChart(resumen),
              _buildUltimasTransacciones(context, resumen),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, String nombre) {
    final mes = DateFormat('MMM yyyy', 'es').format(DateTime.now());
    return AppBar(
      backgroundColor: AppColors.dark,
      title: Row(children: [
        Container(
          width: 34,
          height: 34,
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
              style: TextStyle(
                  fontSize: 10, color: AppColors.goldLight, letterSpacing: 1)),
        ]),
      ]),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
            ),
          ),
        ),
      ],
    );
  }

  // ── KPI Cards ─────────────────────────────────────────────────────────────
  Widget _buildKPIs(DashboardResumen r) {
    final fmt = NumberFormat('#,##0.00');
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.55,
      children: [
        _KpiCard(
          label: 'Ingresos',
          value: 'L ${fmt.format(r.totalIngresos)}',
          subtitle: 'Este mes',
          icon: Icons.trending_up,
          color: AppColors.green,
        ),
        _KpiCard(
          label: 'Gastos',
          value: 'L ${fmt.format(r.totalGastos)}',
          subtitle: 'Este mes',
          icon: Icons.trending_down,
          color: AppColors.redLight,
        ),
        _KpiCard(
          label: 'Saldo',
          value: 'L ${fmt.format(r.saldo)}',
          subtitle: 'Disponible',
          icon: Icons.account_balance_wallet_outlined,
          color: r.saldo >= 0 ? AppColors.gold : AppColors.redLight,
        ),
        _KpiCard(
          label: 'Diezmadores',
          value: '${r.diezmadores}/${r.totalMiembros}',
          subtitle: 'miembros',
          icon: Icons.people_outline,
          color: AppColors.blue,
        ),
      ],
    );
  }

  // ── Alerta presupuesto ────────────────────────────────────────────────────
  Widget _buildAlerts(DashboardResumen r) {
    if (r.totalGastos <= r.totalIngresos * 0.8) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFFFD54F)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Color(0xFF6D4C00), size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Los gastos representan más del 80% de los ingresos.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6D4C00)),
          ),
        ),
      ]),
    );
  }

  // ── Gráfica de barras ─────────────────────────────────────────────────────
  Widget _buildBarChart(WidgetRef ref) {
    final futuro = ref.watch(
      FutureProvider<List<Map<String, dynamic>>>(
        (ref) => ref.watch(dashboardServiceProvider).datosGraficaMensual(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Ingresos vs Gastos',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const Spacer(),
          _legendDot(AppColors.green, 'Ingresos'),
          const SizedBox(width: 10),
          _legendDot(AppColors.orange, 'Gastos'),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: futuro.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2),
            ),
            error: (e, _) => Center(
              child: Text('Error: $e', style: const TextStyle(fontSize: 12)),
            ),
            data: (datos) => datos.isEmpty
                ? const Center(
                    child: Text('Sin datos',
                        style: TextStyle(color: AppColors.textMuted)))
                : BarChart(BarChartData(
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= datos.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              datos[idx]['label'] as String,
                              style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted),
                            );
                          },
                        ),
                      ),
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: datos.asMap().entries.map((e) {
                      final d = e.value;
                      return BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(
                          toY: ((d['ingresos'] as double) / 1000),
                          color: AppColors.green.withOpacity(0.85),
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: ((d['gastos'] as double) / 1000),
                          color: AppColors.orange.withOpacity(0.85),
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ]);
                    }).toList(),
                  )),
          ),
        ),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) => Row(children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]);

  // ── Dona por tipo de ingreso ──────────────────────────────────────────────
  Widget _buildDonutChart(DashboardResumen r) {
    if (r.ingresosPorTipo.isEmpty) return const SizedBox.shrink();

    const colors = [
      AppColors.gold,
      AppColors.green,
      AppColors.blue,
      AppColors.orange,
      AppColors.purple,
    ];
    final entries = r.ingresosPorTipo.entries.toList();
    final total = r.totalIngresos;
    const labels = {
      'diezmo': 'Diezmos',
      'ofrenda': 'Ofrendas',
      'donacion': 'Donaciones',
      'primicia': 'Primicias',
      'misiones': 'Misiones',
    };

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
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
            width: 90,
            height: 90,
            child: PieChart(PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              sections: entries.asMap().entries.map((e) {
                final pct = total > 0 ? e.value.value / total : 0;
                return PieChartSectionData(
                  color: colors[e.key % colors.length],
                  value: e.value.value,
                  title: '${(pct * 100).toStringAsFixed(0)}%',
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
                final pct = total > 0 ? e.value.value / total * 100 : 0;
                final label = labels[e.value.key] ?? e.value.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textDark)),
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

  // ── Últimas transacciones ─────────────────────────────────────────────────
  Widget _buildUltimasTransacciones(BuildContext context, DashboardResumen r) {
    final fmt = DateFormat('dd/MM/yy');

    final todas = <Map<String, dynamic>>[];

    for (final i in r.ultimasTransaccionesIngreso) {
      todas.add({
        'fecha': i.fecha,
        'titulo': i.tipo.label,
        'sub': '${fmt.format(i.fecha)} · ${i.metodo.label}',
        'monto': '+L ${NumberFormat('#,##0.00').format(i.monto)}',
        'isPositive': true,
        'color': AppColors.green,
        'bg': AppColors.greenBg,
        'icon': Icons.arrow_downward_rounded,
      });
    }

    for (final g in r.ultimasTransaccionesGasto) {
      todas.add({
        'fecha': g.fecha,
        'titulo': g.descripcion,
        'sub': '${fmt.format(g.fecha)} · ${g.proveedor}',
        'monto': '-L ${NumberFormat('#,##0.00').format(g.monto)}',
        'isPositive': false,
        'color': AppColors.redLight,
        'bg': AppColors.redBg,
        'icon': Icons.arrow_upward_rounded,
      });
    }

    todas.sort(
        (a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
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
                  style: TextStyle(fontSize: 11, color: AppColors.gold)),
            ),
          ]),
        ),
        ...todas.take(6).map((t) => Column(children: [
              const Divider(height: 1, color: AppColors.borderLight),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (t['bg'] as Color),
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

// ── KPI Card widget ───────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const Spacer(),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5)),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
