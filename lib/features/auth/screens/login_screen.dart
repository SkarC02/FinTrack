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
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 52),
              _buildHero(),
              const SizedBox(height: 36),
              _buildForm(),
              const SizedBox(height: 32),
              _buildBottomLink(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.dark3,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderDark, width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: AppColors.gold.withOpacity(0.15),
                  blurRadius: 28,
                  offset: const Offset(0, 8))
            ],
          ),
          child:
              const Icon(Icons.church_rounded, color: AppColors.gold, size: 32),
        ),
        const SizedBox(height: 20),
        Text('Bienvenido a FinTrack',
            style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 6),
        Text('Sistema de Contabilidad de la Iglesia',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(99))),
          const SizedBox(width: 6),
          Container(
              width: 10,
              height: 3,
              decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(99))),
          const SizedBox(width: 6),
          Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(99))),
        ]),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMsg != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                border: Border.all(color: AppColors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline,
                    color: AppColors.redLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_errorMsg!,
                        style: const TextStyle(
                            color: AppColors.redLight, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          const Text('CORREO ELECTRÓNICO',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: AppColors.goldDim)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            decoration: const InputDecoration(
              hintText: 'correo@iglesia.hn',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const Text('CONTRASEÑA',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: AppColors.goldDim)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            validator: Validators.password,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _rememberMe ? AppColors.gold : AppColors.dark3,
                      border: Border.all(
                          color: _rememberMe
                              ? AppColors.gold
                              : AppColors.borderDark,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _rememberMe
                        ? const Icon(Icons.check,
                            color: AppColors.dark, size: 13)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  const Text('Recordarme',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMutedLight)),
                ]),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showForgotPassword(context),
                child: const Text('¿Olvidé mi contraseña?',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.dark, strokeWidth: 2))
                  : const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Iniciar Sesión'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('¿No tienes cuenta? ',
          style: TextStyle(
              fontSize: 14, color: AppColors.textMutedLight.withOpacity(0.8))),
      GestureDetector(
        onTap: () => context.go(AppRoutes.register),
        child: const Text('Regístrate aquí',
            style: TextStyle(
                color: AppColors.gold,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
    ]);
  }

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark2,
        title: const Text('Recuperar Contraseña'),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Tu correo electrónico.'),
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
