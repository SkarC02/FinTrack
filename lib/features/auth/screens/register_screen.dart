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

  // Paso 1
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _form1Key = GlobalKey<FormState>();

  // Paso 2
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _form2Key = GlobalKey<FormState>();
  bool _obscure1 = true;
  bool _obscure2 = true;
  int _passStrength = 0;

  // Paso 3
  UserRole _selectedRole = UserRole.miembro;
  bool _termsAccepted = false;
  bool _loading = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0 && !_form1Key.currentState!.validate()) return;
    if (_step == 1 && !_form2Key.currentState!.validate()) return;
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
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
      backgroundColor: AppColors.white,
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

  // ── Top bar ────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: _prevStep,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Crear Cuenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            fontFamily:
                Theme.of(context).textTheme.displayMedium?.fontFamily,
          ),
        ),
      ]),
    );
  }

  // ── Steps indicator ────────────────────────────────────
  Widget _buildStepsIndicator() {
    final labels = ['Datos', 'Seguridad', 'Rol'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(children: [
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
                  decoration: BoxDecoration(
                    color: lineIdx < _step
                        ? AppColors.gold
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: i == _step
                      ? AppColors.gold
                      : i < _step
                          ? AppColors.green
                          : AppColors.textMutedLight,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _stepDot(int n, {required bool isDone, required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? AppColors.green
            : isActive
                ? AppColors.gold
                : AppColors.cream2,
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: AppColors.gold.withOpacity(0.3), blurRadius: 10)
              ]
            : null,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, color: Colors.white, size: 15)
            : Text(
                '$n',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive ? AppColors.white : AppColors.textMuted,
                ),
              ),
      ),
    );
  }

  // ── PASO 1: Datos personales ───────────────────────────
  Widget _step1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form1Key,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          _stepTitle('Datos Personales', 'Completa tu información de miembro'),
          const SizedBox(height: 24),
          _label('NOMBRE COMPLETO'),
          _field(
            controller: _nombreCtrl,
            hint: 'Juan Carlos López',
            icon: Icons.person_outline,
            validator: Validators.nombre,
          ),
          const SizedBox(height: 14),
          _label('CORREO ELECTRÓNICO'),
          _field(
            controller: _correoCtrl,
            hint: 'correo@iglesia.hn',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          _label('TELÉFONO'),
          _field(
            controller: _telefonoCtrl,
            hint: '+504 9999-9999',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: Validators.telefono,
          ),
          const SizedBox(height: 14),
          _label('DIRECCIÓN'),
          _field(
            controller: _direccionCtrl,
            hint: 'Tu dirección',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 32),
          _nextBtn(),
        ]),
      ),
    );
  }

  // ── PASO 2: Contraseña ─────────────────────────────────
  Widget _step2() {
    final strColors = [
      AppColors.textMutedLight,
      AppColors.redLight,
      AppColors.orange,
      Colors.amber,
      AppColors.green,
    ];
    final strLabels = ['—', 'Muy débil', 'Débil', 'Media', 'Fuerte ✓'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form2Key,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          _stepTitle('Seguridad', 'Crea una contraseña segura'),
          const SizedBox(height: 24),
          _label('CONTRASEÑA'),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure1,
            validator: Validators.password,
            style: const TextStyle(color: AppColors.textDark),
            onChanged: (v) => setState(
                () => _passStrength = Validators.passwordStrength(v)),
            decoration: InputDecoration(
              hintText: 'Mínimo 8 caracteres',
              hintStyle: const TextStyle(color: AppColors.textMutedLight),
              prefixIcon:
                  const Icon(Icons.lock_outline_rounded, color: AppColors.gold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure1
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              ),
              filled: true,
              fillColor: AppColors.cream,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.borderLight, width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.borderLight, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.gold, width: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < _passStrength
                        ? strColors[_passStrength]
                        : AppColors.cream2,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            strLabels[_passStrength],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: strColors[_passStrength],
            ),
          ),
          const SizedBox(height: 16),
          _label('CONFIRMAR CONTRASEÑA'),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscure2,
            validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
            style: const TextStyle(color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Repite la contraseña',
              hintStyle: const TextStyle(color: AppColors.textMutedLight),
              prefixIcon: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.gold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure2
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              ),
              filled: true,
              fillColor: AppColors.cream,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.borderLight, width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.borderLight, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide:
                      const BorderSide(color: AppColors.gold, width: 1.5)),
            ),
          ),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(child: _backBtn()),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _nextBtn()),
          ]),
        ]),
      ),
    );
  }

  // ── PASO 3: Rol ────────────────────────────────────────
  Widget _step3() {
    final roles = [
      (UserRole.miembro, Icons.person_outline, 'Miembro', 'Congregante general'),
      (UserRole.secretario, Icons.assignment_outlined, 'Secretario',
          'Registra ingresos'),
      (UserRole.tesorero, Icons.account_balance_wallet_outlined, 'Tesorero',
          'Gestiona finanzas'),
      (UserRole.pastor, Icons.church_outlined, 'Pastor', 'Accede a reportes'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _stepTitle('Tu Rol', 'Selecciona tu función en la iglesia'),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: roles.map((r) {
                final isSelected = _selectedRole == r.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRole = r.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blueBg
                          : AppColors.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(r.$2,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.textMuted,
                              size: 28),
                          const SizedBox(height: 8),
                          Text(r.$3,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.goldDim
                                    : AppColors.textDark,
                              )),
                          Text(r.$4,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted),
                              textAlign: TextAlign.center),
                        ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Términos
            GestureDetector(
              onTap: () =>
                  setState(() => _termsAccepted = !_termsAccepted),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: _termsAccepted
                            ? AppColors.gold
                            : AppColors.white,
                        border: Border.all(
                          color: _termsAccepted
                              ? AppColors.gold
                              : AppColors.borderLight,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _termsAccepted
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Acepto los Términos de Uso y la Política de Privacidad del Sistema SIC',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.5),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(child: _backBtn()),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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
                            Text('Crear Cuenta',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ]),
          ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────
  Widget _stepTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily:
                    Theme.of(context).textTheme.displayMedium?.fontFamily,
              )),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
        ],
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: AppColors.goldDim,
            )),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMutedLight),
          prefixIcon: Icon(icon, color: AppColors.gold),
          filled: true,
          fillColor: AppColors.cream,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: AppColors.borderLight, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: AppColors.borderLight, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: AppColors.gold, width: 1.5)),
        ),
      );

  Widget _nextBtn() => ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Siguiente',
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 18),
        ]),
      );

  Widget _backBtn() => OutlinedButton(
        onPressed: _prevStep,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          foregroundColor: AppColors.textDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Atrás',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      );
}