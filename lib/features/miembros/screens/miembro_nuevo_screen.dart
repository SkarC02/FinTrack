import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../auth/services/miembro_service.dart';

class MiembroNuevoScreen extends ConsumerStatefulWidget {
  const MiembroNuevoScreen({super.key});

  @override
  ConsumerState<MiembroNuevoScreen> createState() =>
      _MiembroNuevoScreenState();
}

class _MiembroNuevoScreenState extends ConsumerState<MiembroNuevoScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nombre    = TextEditingController();
  final _correo    = TextEditingController();
  final _telefono  = TextEditingController();
  final _direccion = TextEditingController();
  String _rol      = AppConstants.rolMiembro;
  DateTime _fechaMembresia = DateTime.now();

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

    final uid = await ref.read(miembroFormProvider.notifier).crearMiembro(
      nombreCompleto: _nombre.text.trim(),
      correo:         _correo.text.trim(),
      telefono:       _telefono.text.trim(),
      rol:            _rol,
      direccion:      _direccion.text.trim(),
      fechaMembresia: _fechaMembresia,
    );

    if (!mounted) return;

    if (uid != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Miembro creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      context.pushReplacement(
        AppRoutes.miembroDetalle.replaceFirst(':id', uid),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al crear el miembro'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaMembresia,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _fechaMembresia = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(miembroFormProvider);
    final isLoading = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Miembro'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _correo,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _telefono,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _direccion,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _rol,
              decoration: const InputDecoration(
                labelText: 'Rol',
                prefixIcon: Icon(Icons.manage_accounts),
              ),
              items: AppConstants.roles
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(AppConstants.rolesLabel[r] ?? r),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _rol = v!),
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: const Text('Fecha de membresía'),
              subtitle: Text(
                '${_fechaMembresia.day.toString().padLeft(2, '0')}/'
                '${_fechaMembresia.month.toString().padLeft(2, '0')}/'
                '${_fechaMembresia.year}',
              ),
              trailing: TextButton(
                onPressed: _seleccionarFecha,
                child: const Text('Cambiar'),
              ),
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: isLoading ? null : _guardar,
              icon: isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(isLoading ? 'Guardando...' : 'Crear miembro'),
            ),
          ],
        ),
      ),
    );
  }
}