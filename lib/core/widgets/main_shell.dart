import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../theme/app_theme.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/models/app_user.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // Todas las pestañas posibles
static const _allTabs = [
  (icon: Icons.grid_view_rounded,      label: 'Inicio',   path: AppRoutes.dashboard, roles: ['admin','tesorero','secretario','pastor']),
  (icon: Icons.attach_money_rounded,   label: 'Ingresos', path: AppRoutes.ingresos,  roles: ['admin','tesorero','secretario','pastor','miembro']),
  (icon: Icons.receipt_long_rounded,   label: 'Gastos',   path: AppRoutes.gastos,    roles: ['admin','tesorero','secretario','pastor']),
  (icon: Icons.bar_chart_rounded,      label: 'Reportes', path: AppRoutes.reportes,  roles: ['admin','tesorero','secretario','pastor']),
  (icon: Icons.people_outline_rounded, label: 'Miembros', path: AppRoutes.miembros,  roles: ['admin','tesorero','secretario','pastor']),
  (icon: Icons.person_outline_rounded, label: 'Perfil',   path: '/perfil',           roles: ['admin','tesorero','secretario','pastor','miembro']),
];

  int _currentIndex(BuildContext context, List tabs) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      if (loc.startsWith(tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.cream,
        body: child,
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.cream,
        body: child,
      ),
      data: (user) {
        // Filtrar pestañas según el rol del usuario
        final rol = user?.rol.name ?? 'miembro';
        final tabs = _allTabs
            .where((t) => t.roles.contains(rol))
            .toList();

        final idx = _currentIndex(context, tabs);

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: idx.clamp(0, tabs.length - 1),
            onTap: (i) => context.go(tabs[i].path),
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
            items: tabs
                .map((t) => BottomNavigationBarItem(
                      icon: Icon(t.icon, size: 22),
                      label: t.label,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}