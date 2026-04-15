import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic_app/core/services/fcm_service.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';
import '../../../core/constants/firebase_collections.dart';

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
  bool _uploadingImage = false;
  String _correo = '';
  String _rol = '';
  String _codigoSobre = '';
  String _fotoUrl = '';

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final uid = ref.read(authServiceProvider).currentUid;
    if (uid == null) return;

    try {
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
          _fotoUrl = data['fotoUrl'] ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _mostrarOpcionesFoto() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const Text('Foto de perfil',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blueBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.camera_alt_outlined, color: AppColors.blue),
            ),
            title: const Text('Tomar foto',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textDark)),
            subtitle: const Text('Usar la cámara',
                style: TextStyle(color: AppColors.textMuted)),
            onTap: () {
              Navigator.pop(ctx);
              _cambiarFotoPerfil(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.photo_library_outlined,
                  color: AppColors.green),
            ),
            title: const Text('Elegir de galería',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textDark)),
            subtitle: const Text('Seleccionar una imagen',
                style: TextStyle(color: AppColors.textMuted)),
            onTap: () {
              Navigator.pop(ctx);
              _cambiarFotoPerfil(ImageSource.gallery);
            },
          ),
          if (_fotoUrl.isNotEmpty)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.red),
              ),
              title: const Text('Eliminar foto',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _eliminarFoto();
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _cambiarFotoPerfil(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() => _uploadingImage = true);

      final uid = ref.read(authServiceProvider).currentUid;
      if (uid == null) throw Exception('Usuario no autenticado');

      final file = File(image.path);

      final storageRef =
          FirebaseStorage.instance.ref().child('perfiles_usuarios/$uid.jpg');

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      await uploadTask;

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection(FirebaseCollections.usuarios)
          .doc(uid)
          .update({'fotoUrl': downloadUrl});

      if (mounted) {
        setState(() => _fotoUrl = downloadUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Foto de perfil actualizada')),
        );
        context.go('/perfil');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _eliminarFoto() async {
    try {
      final uid = ref.read(authServiceProvider).currentUid;
      if (uid == null) return;

      setState(() => _uploadingImage = true);

      try {
        await FirebaseStorage.instance
            .ref()
            .child('perfiles_usuarios/$uid.jpg')
            .delete();
      } catch (_) {}

      await FirebaseFirestore.instance
          .collection(FirebaseCollections.usuarios)
          .doc(uid)
          .update({'fotoUrl': ''});

      if (mounted) {
        setState(() => _fotoUrl = '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto eliminada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
      await FcmService.instance.limpiarToken();
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
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
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
            Center(
              child: Column(children: [
                GestureDetector(
                  onTap: _uploadingImage ? null : _mostrarOpcionesFoto,
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.gold.withOpacity(0.15),
                      backgroundImage:
                          _fotoUrl.isNotEmpty ? NetworkImage(_fotoUrl) : null,
                      child: _uploadingImage
                          ? const CircularProgressIndicator(
                              color: AppColors.gold, strokeWidth: 2)
                          : _fotoUrl.isEmpty
                              ? Text(_initials,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gold))
                              : null,
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.dark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _uploadingImage ? null : _mostrarOpcionesFoto,
                  child: Text(
                    _fotoUrl.isNotEmpty
                        ? 'Cambiar foto'
                        : 'Agregar foto de perfil',
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_nombreCtrl.text,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(_rolLabel,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldDim)),
                  ),
                  if (_codigoSobre.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cream2,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(_codigoSobre,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted)),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(_correo,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ]),
            ),
            const SizedBox(height: 28),

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
                        Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

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
        child: Text(text,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: AppColors.goldDim)),
      );
}
