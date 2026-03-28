import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.grid_view_rounded,    label: 'Inicio',   path: AppRoutes.dashboard),
    (icon: Icons.attach_money_rounded, label: 'Ingresos', path: AppRoutes.ingresos),
    (icon: Icons.receipt_long_rounded, label: 'Gastos',   path: AppRoutes.gastos),
    (icon: Icons.bar_chart_rounded,    label: 'Reportes', path: AppRoutes.reportes),
    (icon: Icons.more_horiz_rounded,   label: 'Más',      path: AppRoutes.miembros),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => context.go(_tabs[i].path),
        backgroundColor: AppColors.dark,
        selectedItemColor: AppColors.goldLight,
        unselectedItemColor: AppColors.dark5,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        items: _tabs.map((t) => BottomNavigationBarItem(
          icon: Icon(t.icon, size: 24),
          label: t.label,
        )).toList(),
      ),
    );
  }
}