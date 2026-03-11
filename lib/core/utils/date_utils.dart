// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/utils/date_utils.dart
//  Utilidades para manejo de fechas
// ═══════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SICDateUtils {
  SICDateUtils._();

  static final _fmt       = DateFormat('dd/MM/yyyy', 'es');
  static final _fmtLong   = DateFormat('d \'de\' MMMM yyyy', 'es');
  static final _fmtPeriod = DateFormat('yyyy-MM');
  static final _fmtMonth  = DateFormat('MMMM yyyy', 'es');

  // dd/MM/yyyy
  static String format(DateTime date) => _fmt.format(date);

  // "5 de marzo 2025"
  static String formatLong(DateTime date) => _fmtLong.format(date);

  // "2025-03" (para doc ID de resumen mensual)
  static String toPeriod(DateTime date) => _fmtPeriod.format(date);

  // "Marzo 2025"
  static String toMonthLabel(DateTime date) => _fmtMonth.format(date);

  // Primer día del mes
  static DateTime firstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  // Último día del mes
  static DateTime lastDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  // Timestamp → DateTime
  static DateTime fromTimestamp(Timestamp ts) => ts.toDate();

  // DateTime → Timestamp
  static Timestamp toTimestamp(DateTime date) => Timestamp.fromDate(date);

  // "hace 2 horas" / "ayer" / "dd/MM/yyyy"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return format(date);
  }

  // Período actual "2025-03"
  static String currentPeriod() => toPeriod(DateTime.now());
}
