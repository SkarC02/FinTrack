import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../auth/models/miembro_model.dart';
import '../../auth/services/miembro_service.dart';

final _busquedaProvider    = StateProvider<String>((ref) => '');
final _soloActivosProvider = StateProvider<bool>((ref) => true);

class MiembrosListScreen extends ConsumerWidget {
  const MiembrosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soloActivos = ref.watch(_soloActivosProvider);
    final busqueda    = ref.watch(_busquedaProvider).toLowerCase();

    final stream = soloActivos
        ? ref.watch(miembrosActivosStreamProvider)
        : ref.watch(miembrosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros'),
        actions: [
          Row(
            children: [
              Text(
                soloActivos ? 'Activos' : 'Todos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Switch(
                value: soloActivos,
                onChanged: (v) =>
                    ref.read(_soloActivosProvider.notifier).state = v,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, correo o código…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) =>
                  ref.read(_busquedaProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: stream.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (miembros) {
                final filtrados = busqueda.isEmpty
                    ? miembros
                    : miembros.where((m) {
                        return m.nombreCompleto.toLowerCase().contains(busqueda) ||
                            m.correo.toLowerCase().contains(busqueda) ||
                            m.codigoSobre.toLowerCase().contains(busqueda);
                      }).toList();

                if (filtrados.isEmpty) {
                  return const Center(child: Text('No se encontraron miembros'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _MiembroTile(miembro: filtrados[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.miembroNuevo),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo'),
      ),
    );
  }
}

class _MiembroTile extends ConsumerWidget {
  const _MiembroTile({required this.miembro});
  final MiembroModel miembro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: miembro.activo
              ? colorScheme.outlineVariant
              : colorScheme.error.withOpacity(0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: miembro.activo
              ? colorScheme.primaryContainer
              : colorScheme.errorContainer,
          child: Text(
            miembro.nombreCompleto.isNotEmpty
                ? miembro.nombreCompleto[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: miembro.activo
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          miembro.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${miembro.codigoSobre}  •  ${miembro.correo}',
          style: Theme.of(context).textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RolBadge(rol: miembro.rol),
            const SizedBox(width: 8),
            _ToggleActivoButton(miembro: miembro),
          ],
        ),
        onTap: () => context.go(
          AppRoutes.miembroDetalle.replaceFirst(':id', miembro.uid),
        ),
      ),
    );
  }
}

class _RolBadge extends StatelessWidget {
  const _RolBadge({required this.rol});
  final String rol;

  Color _bgColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (rol) {
      AppConstants.rolAdmin      => cs.errorContainer,
      AppConstants.rolPastor     => cs.tertiaryContainer,
      AppConstants.rolTesorero   => cs.secondaryContainer,
      AppConstants.rolSecretario => cs.secondaryContainer,
      _                          => cs.surfaceContainerHighest,
    };
  }

  Color _fgColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (rol) {
      AppConstants.rolAdmin      => cs.onErrorContainer,
      AppConstants.rolPastor     => cs.onTertiaryContainer,
      AppConstants.rolTesorero   => cs.onSecondaryContainer,
      AppConstants.rolSecretario => cs.onSecondaryContainer,
      _                          => cs.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = AppConstants.rolesLabel[rol] ?? rol;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _fgColor(context),
        ),
      ),
    );
  }
}

class _ToggleActivoButton extends ConsumerStatefulWidget {
  const _ToggleActivoButton({required this.miembro});
  final MiembroModel miembro;

  @override
  ConsumerState<_ToggleActivoButton> createState() => _ToggleActivoButtonState();
}

class _ToggleActivoButtonState extends ConsumerState<_ToggleActivoButton> {
  Future<void> _confirmar() async {
    final accion    = widget.miembro.activo ? 'dar de baja' : 'reactivar';
    final eraActivo = widget.miembro.activo;

    final confirma = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text('¿Deseas $accion a ${widget.miembro.nombreCompleto}?'),
        content: Text(
          eraActivo
              ? 'El miembro pasará a estado inactivo.'
              : 'El miembro volverá a estar activo.',
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(eraActivo ? 'Dar de baja' : 'Reactivar'),
          ),
        ],
      ),
    );

    if (confirma != true) return;

    final scaffoldMsg = ScaffoldMessenger.of(context);

    await ref
        .read(miembroFormProvider.notifier)
        .toggleActivo(widget.miembro.uid, eraActivo);

    if (!mounted) return;

    scaffoldMsg.showSnackBar(SnackBar(
      content: Text(eraActivo ? 'Miembro dado de baja' : 'Miembro reactivado'),
      backgroundColor: eraActivo ? Colors.orange : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.miembro.activo ? 'Dar de baja' : 'Reactivar',
      icon: Icon(
        widget.miembro.activo ? Icons.person_off : Icons.person,
        color: widget.miembro.activo
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      onPressed: _confirmar,
    );
  }
}