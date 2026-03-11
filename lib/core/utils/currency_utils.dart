// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/utils/currency_utils.dart
//  Formato de moneda en Lempiras (HNL)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final _formatter = NumberFormat('#,##0.00', 'en_US');
  static final _formatterShort = NumberFormat('#,##0', 'en_US');

  // L.142,500.00
  static String format(double amount) {
    return '${AppConstants.simboloMoneda}${_formatter.format(amount)}';
  }

  // L.142,500 (sin decimales)
  static String formatShort(double amount) {
    return '${AppConstants.simboloMoneda}${_formatterShort.format(amount)}';
  }

  // Parsear string a double
  static double? parse(String value) {
    return double.tryParse(value.replaceAll(',', '').replaceAll('L.', '').trim());
  }

  // Formato compacto: L.142.5K
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${AppConstants.simboloMoneda}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${AppConstants.simboloMoneda}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
