import 'dart:math' as math;

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../models/storage_usage_item.dart';
import '../../theme/app_theme_colors.dart';

class AnalyticsStatCard extends StatelessWidget {
  const AnalyticsStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: colors.mutedText),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsWarningCard extends StatelessWidget {
  const AnalyticsWarningCard({super.key, required this.storages});

  final List<StorageUsageItem> storages;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final names = storages.map((s) => s.name).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF352416) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF7C4520) : const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEA580C),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.warning,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFFFBE8D)
                        : const Color(0xFF9A3412),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.warningBody(names),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFFFCDA8)
                        : const Color(0xFF9A3412),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsSectionCard extends StatelessWidget {
  const AnalyticsSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class AnalyticsPieUsageChart extends StatelessWidget {
  const AnalyticsPieUsageChart({super.key, required this.items});

  final List<StorageUsageItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = items.fold<double>(0, (acc, item) => acc + item.usedBytes);

    return Center(
      child: SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
          painter: _DonutPainter(
            items: items,
            total: total,
            baseColor: isDark ? const Color(0xFF33445E) : colors.headerBorder,
            holeColor: isDark ? colors.cardBackground : colors.shellBackground,
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.items,
    required this.total,
    required this.baseColor,
    required this.holeColor,
  });

  final List<StorageUsageItem> items;
  final double total;
  final Color baseColor;
  final Color holeColor;

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -math.pi / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 76);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.butt
      ..color = baseColor;

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    var currentAngle = startAngle;
    for (final item in items) {
      final sweep = (item.usedBytes / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.butt
        ..color = item.color;

      canvas.drawArc(rect, currentAngle, sweep - 0.03, false, paint);
      currentAngle += sweep;
    }

    final holePaint = Paint()..color = holeColor;
    canvas.drawCircle(size.center(Offset.zero), 56, holePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.total != total ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.holeColor != holeColor;
  }
}

class AnalyticsBarUsageChart extends StatelessWidget {
  const AnalyticsBarUsageChart({super.key, required this.items});

  final List<StorageUsageItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final maxValue = items
        .map((e) => e.totalBytes / (1024 * 1024 * 1024))
        .reduce(math.max);

    return Column(
      children: [
        ...items.map((item) {
          final usedGb = item.usedBytes / (1024 * 1024 * 1024);
          final freeGb = item.freeBytes / (1024 * 1024 * 1024);
          final usedPart = usedGb / maxValue;
          final freePart = freeGb / maxValue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.split(' ').first,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final usedWidth = totalWidth * usedPart;
                    final freeWidth = totalWidth * freePart;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 12,
                        width: totalWidth,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: usedWidth,
                              child: Container(color: const Color(0xFF3B82F6)),
                            ),
                            Positioned(
                              left: usedWidth,
                              top: 0,
                              bottom: 0,
                              width: freeWidth,
                              child: Container(color: const Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        Row(
          children: [
            _LegendItem(
              color: const Color(0xFF3B82F6),
              text: '${l10n.usedSpace} (GB)',
            ),
            const SizedBox(width: 14),
            _LegendItem(
              color: const Color(0xFF10B981),
              text: '${l10n.freeSpace} (GB)',
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: colors.mutedText, fontSize: 12)),
      ],
    );
  }
}

class AnalyticsTipCard extends StatelessWidget {
  const AnalyticsTipCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
    required this.bg,
    required this.titleColor,
    required this.bodyColor,
  });

  final String emoji;
  final String title;
  final String body;
  final Color bg;
  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: bodyColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
