import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';
import '../../../core/constants/firebase_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _correo = '';
  String _rol = '';
  String _codigoSobre = '';

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final uid = ref.read(authServiceProvider).currentUid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection(FirebaseCollections.usuarios)
        .doc(uid)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _nombreCtrl.text = data[FirebaseCollections.nombreCompleto] ?? '';
        _telefonoCtrl.text = data[FirebaseCollections.telefono] ?? '';
        _direccionCtrl.text = data[FirebaseCollections.direccion] ?? '';
        _correo = data[FirebaseCollections.correo] ?? '';
        _rol = data[FirebaseCollections.rol] ?? '';
        _codigoSobre = data[FirebaseCollections.codigoSobre] ?? '';
        _loading = false;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final uid = ref.read(authServiceProvider).currentUid;
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.usuarios)
          .doc(uid)
          .update({
        FirebaseCollections.nombreCompleto: _nombreCtrl.text.trim(),
        FirebaseCollections.telefono: _telefonoCtrl.text.trim(),
        FirebaseCollections.direccion: _direccionCtrl.text.trim(),
        FirebaseCollections.updatedAt: FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Perfil actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark2,
        title: const Text('Cerrar Sesión',
            style: TextStyle(color: AppColors.textLight)),
        content: const Text('¿Estás seguro que deseas cerrar sesión?',
            style: TextStyle(color: AppColors.textMutedLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }

  String get _initials {
    final parts = _nombreCtrl.text.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _nombreCtrl.text.isNotEmpty
        ? _nombreCtrl.text[0].toUpperCase()
        : '?';
  }

  String get _rolLabel {
    const labels = {
      'admin': 'Administrador',
      'tesorero': 'Tesorero',
      'secretario': 'Secretario',
      'pastor': 'Pastor',
      'miembro': 'Miembro',
    };
    return labels[_rol] ?? _rol;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('Mi Perfil',
            style: TextStyle(color: AppColors.textLight)),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Avatar ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.gold.withOpacity(0.15),
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nombreCtrl.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Text(
                          _rolLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldDim,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _correo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Formulario ──────────────────────────────────
            _sectionLabel('NOMBRE COMPLETO'),
            TextFormField(
              controller: _nombreCtrl,
              validator: Validators.nombre,
              decoration: const InputDecoration(
                hintText: 'Tu nombre completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),

            _sectionLabel('TELÉFONO'),
            TextFormField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              validator: Validators.telefono,
              decoration: const InputDecoration(
                hintText: '+504 9999-9999',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),

            _sectionLabel('DIRECCIÓN'),
            TextFormField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(
                hintText: 'Tu dirección',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 28),

            // ── Botón guardar ────────────────────────────────
            ElevatedButton(
              onPressed: _saving ? null : _guardar,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: AppColors.dark)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Guardar Cambios',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // ── Botón cerrar sesión ──────────────────────────
            OutlinedButton(
              onPressed: _cerrarSesion,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.red, width: 1.5),
                foregroundColor: AppColors.red,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            color: AppColors.goldDim,
          ),
        ),
      );
}