// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/widgets/main_shell.dart
//  Shell principal con BottomNavigationBar
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.grid_view_rounded,       label: 'Inicio',    path: AppRoutes.dashboard),
    (icon: Icons.attach_money_rounded,    label: 'Ingresos',  path: AppRoutes.ingresos),
    (icon: Icons.receipt_long_rounded,    label: 'Gastos',    path: AppRoutes.gastos),
    (icon: Icons.bar_chart_rounded,       label: 'Reportes',  path: AppRoutes.reportes),
    (icon: Icons.more_horiz_rounded,      label: 'Más',       path: AppRoutes.miembros),
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
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.dark,
          border: Border(top: BorderSide(color: AppColors.borderDark)),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.dark,
          indicatorColor: AppColors.gold.withOpacity(0.15),
          selectedIndex: idx,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => context.go(_tabs[i].path),
          destinations: _tabs.map((t) => NavigationDestination(
            icon: Icon(t.icon,
                color: AppColors.dark5,
                size: 24),
            selectedIcon: Icon(t.icon,
                color: AppColors.goldLight,
                size: 24),
            label: t.label,
          )).toList(),
        ),
      ),
    );
  }
}
