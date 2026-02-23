import 'dart:math' as math;

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/storage_formatters.dart';
import '../data/storage_usage_mock_data.dart';
import '../models/storage_usage_item.dart';
import '../utils/tab_navigation.dart';
import '../widgets/app_page_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mobile_screen_shell.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalUsed = storageUsageItems.fold<double>(
      0,
      (acc, item) => acc + item.usedBytes,
    );
    final totalSpace = storageUsageItems.fold<double>(
      0,
      (acc, item) => acc + item.totalBytes,
    );
    final totalFree = totalSpace - totalUsed;

    final almostFullStorages = storageUsageItems
        .where((s) => s.usagePercent >= 90)
        .toList();

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            AppPageHeader(
              title: l10n.analytics,
              subtitle: l10n.analyticsSubtitle,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            isDark: isDark,
                            icon: Icons.storage,
                            label: l10n.totalSpace,
                            value: formatBytes(totalSpace),
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFDBEAFE),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            isDark: isDark,
                            icon: Icons.task_alt,
                            label: l10n.usedSpace,
                            value: formatBytes(totalUsed),
                            iconColor: const Color(0xFF16A34A),
                            iconBg: const Color(0xFFDCFCE7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            isDark: isDark,
                            icon: Icons.trending_up,
                            label: l10n.freeSpace,
                            value: formatBytes(totalFree),
                            iconColor: const Color(0xFF9333EA),
                            iconBg: const Color(0xFFF3E8FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (almostFullStorages.isNotEmpty) ...[
                      _WarningCard(
                        storages: almostFullStorages,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SectionCard(
                      isDark: isDark,
                      title: l10n.distributionByStorage,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: _PieUsageChart(items: storageUsageItems),
                          ),
                          const SizedBox(height: 10),
                          ...storageUsageItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: item.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Color(0xFFA8B5C9),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatBytes(item.usedBytes),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      isDark: isDark,
                      title: l10n.usageVsFree,
                      child: _BarUsageChart(items: storageUsageItems),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      isDark: isDark,
                      title: l10n.recommendations,
                      child: Column(
                        children: [
                          _TipCard(
                            emoji: '💡',
                            title: l10n.tipOptimizeDropboxTitle,
                            body: l10n.tipOptimizeDropboxBody,
                            bg: Color(0xFF182A4A),
                            titleColor: Color(0xFFEAF2FF),
                            bodyColor: Color(0xFF98A8BF),
                          ),
                          SizedBox(height: 10),
                          _TipCard(
                            emoji: '✨',
                            title: l10n.tipUseIcloudTitle,
                            body: l10n.tipUseIcloudBody,
                            bg: Color(0xFF18323A),
                            titleColor: Color(0xFFEAF2FF),
                            bodyColor: Color(0xFF98A8BF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              activeIndex: 2,
              onTap: (index) => handleBottomNavTap(context, 2, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2D44) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF31435C) : const Color(0xFFDCE5F2),
        ),
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
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Color(0xFF93A1B7) : Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.storages, required this.isDark});

  final List<StorageUsageItem> storages;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
                    color: isDark ? Color(0xFFFFBE8D) : Color(0xFF9A3412),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.warningBody(names),
                  style: TextStyle(
                    color: isDark ? Color(0xFFFFCDA8) : Color(0xFF9A3412),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.isDark,
  });

  final String title;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2D44) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF31435C) : const Color(0xFFDCE5F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Color(0xFF0F172A),
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

class _PieUsageChart extends StatelessWidget {
  const _PieUsageChart({required this.items});

  final List<StorageUsageItem> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (acc, item) => acc + item.usedBytes);

    return Center(
      child: SizedBox(
        width: 210,
        height: 210,
        child: CustomPaint(
          painter: _DonutPainter(items: items, total: total),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.items, required this.total});

  final List<StorageUsageItem> items;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -math.pi / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 76);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFF33445E);

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

    final holePaint = Paint()..color = const Color(0xFF1F2D44);
    canvas.drawCircle(size.center(Offset.zero), 56, holePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.total != total;
  }
}

class _BarUsageChart extends StatelessWidget {
  const _BarUsageChart({required this.items});

  final List<StorageUsageItem> items;

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(
                    color: Color(0xFFA8B5C9),
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
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF93A1B7), fontSize: 12),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
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
