import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _pageCtrl = PageController();
  int _step = 0; 

  final _nombreCtrl    = TextEditingController();
  final _correoCtrl    = TextEditingController();
  final _telefonoCtrl  = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _form1Key = GlobalKey<FormState>();

  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  final _form2Key = GlobalKey<FormState>();
  bool _obscure1 = true;
  bool _obscure2 = true;
  int _passStrength = 0;

  UserRole _selectedRole = UserRole.miembro;
  bool _termsAccepted = false;

  bool _loading = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nombreCtrl.dispose(); _correoCtrl.dispose();
    _telefonoCtrl.dispose(); _direccionCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0 && !_form1Key.currentState!.validate()) return;
    if (_step == 1 && !_form2Key.currentState!.validate()) return;
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _submit() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos de uso')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).registerWithEmail(
        email: _correoCtrl.text,
        password: _passCtrl.text,
        nombreCompleto: _nombreCtrl.text,
        telefono: _telefonoCtrl.text,
        direccion: _direccionCtrl.text,
        rol: _selectedRole,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthService.errorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildStepsIndicator(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [_step1(), _step2(), _step3()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: _prevStep,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.dark3,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textLight, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Text('Crear Cuenta', style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 18)),
      ]),
    );
  }

  Widget _buildStepsIndicator() {
    final labels = ['Datos', 'Seguridad', 'Rol'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (i) {
              if (i.isEven) {
                final idx = i ~/ 2;
                final isDone = idx < _step;
                final isActive = idx == _step;
                return _stepDot(idx + 1, isDone: isDone, isActive: isActive);
              } else {
                final lineIdx = i ~/ 2;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 2,
                    color: lineIdx < _step ? AppColors.gold : AppColors.dark4,
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Text(labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: i == _step ? AppColors.gold
                      : i < _step ? AppColors.greenLight
                      : AppColors.textMutedLight,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(int n, {required bool isDone, required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppColors.green : isActive ? AppColors.gold : AppColors.dark3,
        boxShadow: isActive ? [BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 12)] : null,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : Text('$n', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: isActive ? AppColors.dark : AppColors.textMutedLight)),
      ),
    );
  }

  Widget _step1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form1Key,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Text('Datos Personales', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Completa tu información de miembro', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          _label('NOMBRE COMPLETO'),
          TextFormField(controller: _nombreCtrl, validator: Validators.nombre,
            decoration: const InputDecoration(hintText: 'Juan Carlos López', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 14),
          _label('CORREO ELECTRÓNICO'),
          TextFormField(controller: _correoCtrl, validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'correo@iglesia.hn', prefixIcon: Icon(Icons.email_outlined))),
          const SizedBox(height: 14),
          _label('TELÉFONO'),
          TextFormField(controller: _telefonoCtrl, validator: Validators.telefono,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+504 9999-9999', prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: 14),
          _label('DIRECCIÓN'),
          TextFormField(controller: _direccionCtrl,
            decoration: const InputDecoration(hintText: 'Tu dirección', prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 32),
          _nextButton(),
        ]),
      ),
    );
  }

  Widget _step2() {
    final strLabels = ['—', 'Muy débil', 'Débil', 'Media', 'Fuerte ✓'];
    final strColors = [AppColors.textMutedLight, AppColors.redLight, AppColors.orange, Colors.amber, AppColors.greenLight];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form2Key,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Text('Seguridad', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Crea una contraseña segura', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          _label('CONTRASEÑA'),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure1,
            validator: Validators.password,
            onChanged: (v) => setState(() => _passStrength = Validators.passwordStrength(v)),
            decoration: InputDecoration(
              hintText: 'Mínimo 8 caracteres',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Barras de fuerza
          Row(children: List.generate(4, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < _passStrength ? strColors[_passStrength] : AppColors.dark4,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ))),
          const SizedBox(height: 5),
          Text(strLabels[_passStrength], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: strColors[_passStrength], fontFamily: 'monospace')),
          const SizedBox(height: 16),
          _label('CONFIRMAR CONTRASEÑA'),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscure2,
            validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
            decoration: InputDecoration(
              hintText: 'Repite la contraseña',
              prefixIcon: const Icon(Icons.check_circle_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(child: _backButton()),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _nextButton()),
          ]),
        ]),
      ),
    );
  }

  Widget _step3() {
    final roles = [
      (UserRole.miembro, '🙏', 'Miembro', 'Congregante general'),
      (UserRole.secretario, '📋', 'Secretario', 'Registra ingresos'),
      (UserRole.tesorero, '💰', 'Tesorero', 'Gestiona finanzas'),
      (UserRole.pastor, '✝️', 'Pastor', 'Accede a reportes'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text('Tu Rol', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Selecciona tu función en la iglesia', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5,
          children: roles.map((r) {
            final isSelected = _selectedRole == r.$1;
            return GestureDetector(
              onTap: () => setState(() => _selectedRole = r.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.gold.withOpacity(0.1) : AppColors.dark3,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : AppColors.borderDark,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(r.$2, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(r.$3, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                  Text(r.$4, style: const TextStyle(fontSize: 9, color: AppColors.textMutedLight), textAlign: TextAlign.center),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Términos
        GestureDetector(
          onTap: () => setState(() => _termsAccepted = !_termsAccepted),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20, margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: _termsAccepted ? AppColors.gold : AppColors.dark3,
                border: Border.all(color: _termsAccepted ? AppColors.gold : AppColors.borderDark, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: _termsAccepted ? const Icon(Icons.check, color: AppColors.dark, size: 13) : null,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Acepto los Términos de Uso y la Política de Privacidad del Sistema SIC',
                style: TextStyle(fontSize: 12, color: AppColors.textMutedLight, height: 1.5)),
            ),
          ]),
        ),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(child: _backButton()),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: AppColors.dark, strokeWidth: 2))
                : const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Crear Cuenta'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ]),
          )),
        ]),
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: AppColors.goldDim)),
  );

  Widget _nextButton() => ElevatedButton(
    onPressed: _nextStep,
    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Text('Siguiente'), SizedBox(width: 8),
      Icon(Icons.arrow_forward_rounded, size: 18),
    ]),
  );

  Widget _backButton() => OutlinedButton(
    onPressed: _prevStep,
    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    child: const Text('Atrás'),
  );
}
