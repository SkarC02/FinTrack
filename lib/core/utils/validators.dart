import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Mínimo ${AppConstants.minPasswordLength} caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != original) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  static String? nombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (value.trim().length > AppConstants.maxNombreLength) {
      return 'El nombre es demasiado largo';
    }
    return null;
  }

  static String? monto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es requerido';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Ingresa un monto válido (ej: 1500.00)';
    }
    if (parsed < AppConstants.montoMinimo) {
      return 'El monto debe ser mayor a cero';
    }
    if (parsed > AppConstants.montoMaximo) {
      return 'El monto excede el límite permitido';
    }
    return null;
  }

  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opcional
    final clean = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (clean.length < 8) {
      return 'Teléfono inválido (mínimo 8 dígitos)';
    }
    return null;
  }

  static String? notas(String? value) {
    if (value != null && value.length > AppConstants.maxNotasLength) {
      return 'Máximo ${AppConstants.maxNotasLength} caracteres';
    }
    return null;
  }

  static int passwordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  static String passwordStrengthLabel(int score) {
    switch (score) {
      case 1: return 'Muy débil';
      case 2: return 'Débil';
      case 3: return 'Media';
      case 4: return 'Fuerte ✓';
      default: return '—';
    }
  }
}
