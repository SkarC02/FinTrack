import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/firebase_collections.dart';
import '../../auth/models/miembro_model.dart';
import '../../auth/services/miembro_service.dart';

final _aportesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.ingresos)
      .where(FirebaseCollections.memberId, isEqualTo: uid)
      .orderBy(FirebaseCollections.fecha, descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
});

class MiembroDetailScreen extends ConsumerStatefulWidget {
  const MiembroDetailScreen({super.key, required this.miembroId});
  final String miembroId;

  @override
  ConsumerState<MiembroDetailScreen> createState() =>
      _MiembroDetailScreenState();
}

class _MiembroDetailScreenState extends ConsumerState<MiembroDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final miembroAsync =
        ref.watch(miembroByIdProvider(widget.miembroId));

    return miembroAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (miembro) {
        if (miembro == null) {
          return const Scaffold(
            body: Center(child: Text('Miembro no encontrado')),
          );
        }
        return _buildScaffold(miembro);
      },
    );
  }

  Widget _buildScaffold(MiembroModel miembro) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(miembro.nombreCompleto),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => _mostrarFormularioEditar(miembro),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Perfil'),
            Tab(icon: Icon(Icons.history), text: 'Aportes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PerfilTab(miembro: miembro),
          _AportesTab(miembroId: miembro.uid),
        ],
      ),
    );
  }

  void _mostrarFormularioEditar(MiembroModel miembro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditarMiembroSheet(miembro: miembro),
    );
  }
}

class _PerfilTab extends StatelessWidget {
  const _PerfilTab({required this.miembro});
  final MiembroModel miembro;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + estado
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    miembro.nombreCompleto.isNotEmpty
                        ? miembro.nombreCompleto[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  miembro.nombreCompleto,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                _StatusChip(activo: miembro.activo),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _InfoCard(children: [
            _InfoRow(Icons.badge,       'Código sobre',    miembro.codigoSobre),
            _InfoRow(Icons.email,       'Correo',          miembro.correo),
            _InfoRow(Icons.phone,       'Teléfono',        miembro.telefono),
            _InfoRow(Icons.home,        'Dirección',       miembro.direccion.isEmpty ? '—' : miembro.direccion),
            _InfoRow(Icons.manage_accounts, 'Rol',         miembro.rolLabel),
            _InfoRow(Icons.calendar_month, 'Miembro desde', fmt.format(miembro.fechaMembresia)),
          ]),
        ],
      ),
    );
  }
}

class _AportesTab extends ConsumerWidget {
  const _AportesTab({required this.miembroId});
  final String miembroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aportesAsync = ref.watch(_aportesProvider(miembroId));
    final fmtFecha     = DateFormat('dd/MM/yyyy');
    final fmtMonto     = NumberFormat(
        '${AppConstants.simboloMoneda} #,##0.00', 'es_HN');

    return aportesAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('Error: $e')),
      data: (aportes) {
        if (aportes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text('Sin aportes registrados'),
              ],
            ),
          );
        }

        final total = aportes.fold<double>(
            0, (sum, a) => sum + ((a[FirebaseCollections.monto] ?? 0) as num).toDouble());

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total aportado',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    fmtMonto.format(total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: aportes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final a     = aportes[i];
                  final tipo  = a[FirebaseCollections.tipo] as String? ?? '';
                  final monto = ((a[FirebaseCollections.monto] ?? 0) as num).toDouble();
                  final fecha = (a[FirebaseCollections.fecha] as Timestamp?)?.toDate();

                  return ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: Text(
                      AppConstants.tiposIngresoLabel[tipo] ?? tipo,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      fecha != null ? fmtFecha.format(fecha) : '—',
                    ),
                    trailing: Text(
                      fmtMonto.format(monto),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}


class _EditarMiembroSheet extends ConsumerStatefulWidget {
  const _EditarMiembroSheet({required this.miembro});
  final MiembroModel miembro;

  @override
  ConsumerState<_EditarMiembroSheet> createState() =>
      _EditarMiembroSheetState();
}

class _EditarMiembroSheetState extends ConsumerState<_EditarMiembroSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _correo;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  late String _rol;

  @override
  void initState() {
    super.initState();
    _nombre    = TextEditingController(text: widget.miembro.nombreCompleto);
    _correo    = TextEditingController(text: widget.miembro.correo);
    _telefono  = TextEditingController(text: widget.miembro.telefono);
    _direccion = TextEditingController(text: widget.miembro.direccion);
    _rol       = widget.miembro.rol;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.miembro.copyWith(
      nombreCompleto: _nombre.text.trim(),
      correo:         _correo.text.trim(),
      telefono:       _telefono.text.trim(),
      direccion:      _direccion.text.trim(),
      rol:            _rol,
    );

    final ok = await ref
        .read(miembroFormProvider.notifier)
        .actualizarMiembro(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Miembro actualizado' : 'Error al guardar'),
        backgroundColor:
            ok ? Colors.green : Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(miembroFormProvider);
    final isLoading = formState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Editar miembro',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nombre,
                decoration:
                    const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _correo,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Dropdown rol
              DropdownButtonFormField<String>(
                initialValue: _rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: AppConstants.roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(AppConstants.rolesLabel[r] ?? r),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _rol = v!),
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: isLoading ? null : _guardar,
                child: isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.activo});
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      label: Text(activo ? 'Activo' : 'Inactivo'),
      avatar: Icon(
        activo ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: activo ? cs.onSecondaryContainer : cs.onErrorContainer,
      ),
      backgroundColor:
          activo ? cs.secondaryContainer : cs.errorContainer,
      labelStyle: TextStyle(
        color: activo ? cs.onSecondaryContainer : cs.onErrorContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children
              .expand((w) => [w, const Divider(height: 20)])
              .toList()
            ..removeLast(),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline)),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}