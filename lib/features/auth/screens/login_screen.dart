import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _rememberMe = false;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            email: _emailCtrl.text,
            password: _passCtrl.text,
          );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMsg = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ── Espacio para logo propio ──────────────────
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 254, 254, 254),
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2), width: 1.5),
                  ),
                  child: ClipRRect(
                    //borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'lib/core/assets/LogoFinTrack.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Títulos ───────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistema de Contabilidad Iglesia',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── Error ─────────────────────────────────────
              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMsg!,
                          style: const TextStyle(
                              color: AppColors.red, fontSize: 13)),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              // ── Formulario ────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    _fieldLabel('CORREO ELECTRÓNICO'),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'correo@iglesia.hn',
                        hintStyle:
                            const TextStyle(color: AppColors.textMutedLight),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.gold),
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                              color: AppColors.borderLight, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                              color: AppColors.borderLight, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                              color: AppColors.gold, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    _fieldLabel('CONTRASEÑA'),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      validator: Validators.password,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle:
                            const TextStyle(color: AppColors.textMutedLight),
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.gold),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                        filled: true,
                        fillColor: AppColors.cream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                              color: AppColors.borderLight, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                              color: AppColors.borderLight, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                              color: AppColors.gold, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Recordarme + olvidé contraseña
                    Row(children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _rememberMe
                                  ? AppColors.gold
                                  : AppColors.white,
                              border: Border.all(
                                color: _rememberMe
                                    ? AppColors.gold
                                    : AppColors.borderLight,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _rememberMe
                                ? const Icon(Icons.check,
                                    color: AppColors.white, size: 14)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          const Text('Recordarme',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textMuted)),
                        ]),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _showForgotPassword(context),
                        child: const Text(
                          '¿Olvidé mi contraseña?',
                          style: TextStyle(fontSize: 10, color: AppColors.gold),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Botón login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: AppColors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Iniciar Sesión',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Row(children: [
                      const Expanded(
                          child: Divider(color: AppColors.borderLight)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'o continúa con',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Expanded(
                          child: Divider(color: AppColors.borderLight)),
                    ]),
                    const SizedBox(height: 20),

                    // Botón Google
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(
                              color: AppColors.borderLight, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          foregroundColor: AppColors.textDark,
                        ),
                        icon: const Text('G',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4285F4))),
                        label: const Text('Continuar con Google',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Link registro ─────────────────────────────
              Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('¿No tienes cuenta? ',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.register),
                    child: const Text('Regístrate aquí',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
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

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Recuperar Contraseña',
            style: TextStyle(color: AppColors.textDark)),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textDark),
          decoration: const InputDecoration(hintText: 'Tu correo electrónico'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                await ref
                    .read(authServiceProvider)
                    .sendPasswordResetEmail(ctrl.text);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✉️ Correo de recuperación enviado')),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
