// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/widgets/sic_widgets.dart
//  Widgets reutilizables de SIC
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── KPI CARD ─────────────────────────────────────────────────────────────────
class SICKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final String? emoji;
  final Color accentColor;

  const SICKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.emoji,
    this.accentColor = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emoji != null)
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text(emoji!, style: const TextStyle(fontSize: 14))),
            ),
          if (emoji != null) const SizedBox(height: 6),
          Text(label.toUpperCase(), style: const TextStyle(
            fontSize: 9, fontWeight: FontWeight.w800,
            letterSpacing: 1.2, color: AppColors.textMuted,
          )),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(
            fontFamily: 'DMSans', fontSize: 17,
            fontWeight: FontWeight.w500, color: AppColors.textDark,
          )),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TRANSACTION TILE ─────────────────────────────────────────────────────────
class SICTransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final Color iconBg;
  final String iconEmoji;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SICTransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isPositive = true,
    this.iconBg = AppColors.greenBg,
    this.iconEmoji = '💰',
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(iconEmoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(
                fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600,
                color: isPositive ? AppColors.green : AppColors.red,
              )),
              if (trailing != null) trailing!,
            ],
          ),
        ]),
      ),
    );
  }
}

// ── STATUS CHIP ───────────────────────────────────────────────────────────────
class SICStatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const SICStatusChip({super.key, required this.label, required this.bg, required this.fg});

  factory SICStatusChip.pagado() => const SICStatusChip(label: 'Pagado', bg: Color(0xFFD4EDDA), fg: Color(0xFF155724));
  factory SICStatusChip.pendiente() => const SICStatusChip(label: 'Pendiente', bg: Color(0xFFFFF3CD), fg: Color(0xFF856404));
  factory SICStatusChip.registrado() => const SICStatusChip(label: 'Registrado', bg: Color(0xFFD4EDDA), fg: Color(0xFF155724));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

// ── SECTION LABEL ─────────────────────────────────────────────────────────────
class SICSectionLabel extends StatelessWidget {
  final String text;
  const SICSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
    child: Text(text.toUpperCase(), style: const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w800,
      letterSpacing: 1.5, color: AppColors.textMuted,
    )),
  );
}

// ── LOADING OVERLAY ───────────────────────────────────────────────────────────
class SICLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const SICLoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isLoading)
        Container(
          color: Colors.black45,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ),
    ]);
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────
class SICEmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  const SICEmptyState({
    super.key,
    this.emoji = '📭',
    required this.title,
    this.subtitle = '',
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ]),
      ),
    );
  }
}

// ── CARD CONTAINER ────────────────────────────────────────────────────────────
class SICCard extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final EdgeInsets? padding;

  const SICCard({super.key, this.header, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 0),
            child: header!,
          ),
          const Divider(height: 1, color: Color(0xFFF5EDD8)),
        ],
        Padding(
          padding: padding ?? const EdgeInsets.all(14),
          child: child,
        ),
      ]),
    );
  }
}

// ── PROGRESS BAR ─────────────────────────────────────────────────────────────
class SICProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final Color color;

  const SICProgressBar({super.key, required this.value, this.color = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        backgroundColor: AppColors.cream2,
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: 5,
      ),
    );
  }
}
