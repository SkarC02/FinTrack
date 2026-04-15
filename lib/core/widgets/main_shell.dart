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

  int _currentIndex(BuildContext context, List<Map<String, dynamic>> tabs) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      if (loc.startsWith(tabs[i]['path'] as String)) return i;
    }
    return 0;
  }

  List<Map<String, dynamic>> _tabsParaRol(UserRole rol) {
    final todos = [
      {
        'icon': Icons.grid_view_rounded,
        'label': 'Inicio',
        'path': AppRoutes.dashboard,
        'roles': [
          UserRole.admin,
          UserRole.tesorero,
          UserRole.secretario,
          UserRole.pastor
        ],
      },
      {
        'icon': Icons.attach_money_rounded,
        'label': 'Ingresos',
        'path': AppRoutes.ingresos,
        'roles': [
          UserRole.admin,
          UserRole.tesorero,
          UserRole.secretario,
          UserRole.pastor,
          UserRole.miembro
        ],
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Gastos',
        'path': AppRoutes.gastos,
        'roles': [
          UserRole.admin,
          UserRole.tesorero,
          UserRole.secretario,
          UserRole.pastor
        ],
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Reportes',
        'path': AppRoutes.reportes,
        'roles': [
          UserRole.admin,
          UserRole.tesorero,
          UserRole.secretario,
          UserRole.pastor
        ],
      },
      {
        'icon': Icons.people_outline_rounded,
        'label': 'Miembros',
        'path': AppRoutes.miembros,
        'roles': [
          UserRole.admin,
          UserRole.tesorero,
          UserRole.secretario,
          UserRole.pastor
        ],
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Perfil',
        'path': '/perfil',
        'roles': [
          UserRole.admin,
          UserRole.tesorero,
          UserRole.secretario,
          UserRole.pastor,
          UserRole.miembro
        ],
      },
    ];

    return todos
        .where((t) => (t['roles'] as List<UserRole>).contains(rol))
        .toList();
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
        final rol = user?.rol ?? UserRole.miembro;
        final tabs = _tabsParaRol(rol);
        final idx = _currentIndex(context, tabs).clamp(0, tabs.length - 1);

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: idx,
            onTap: (i) => context.go(tabs[i]['path'] as String),
            backgroundColor: AppColors.dark,
            selectedItemColor: AppColors.goldLight,
            unselectedItemColor: AppColors.blueBg,
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
                      icon: Icon(t['icon'] as IconData, size: 22),
                      label: t['label'] as String,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
