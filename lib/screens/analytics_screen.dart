import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/storage_usage_item.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        color: const Color(0xFF2D2D2D),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Аналітика',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Статистика використання сховищ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
                                      icon: Icons.storage,
                                      label: 'Всього простору',
                                      value: formatBytes(totalSpace),
                                      iconColor: const Color(0xFF2563EB),
                                      iconBg: const Color(0xFFDBEAFE),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.task_alt,
                                      label: 'Використано',
                                      value: formatBytes(totalUsed),
                                      iconColor: const Color(0xFF16A34A),
                                      iconBg: const Color(0xFFDCFCE7),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.trending_up,
                                      label: 'Вільно',
                                      value: formatBytes(totalFree),
                                      iconColor: const Color(0xFF9333EA),
                                      iconBg: const Color(0xFFF3E8FF),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (almostFullStorages.isNotEmpty) ...[
                                _WarningCard(storages: almostFullStorages),
                                const SizedBox(height: 16),
                              ],
                              _SectionCard(
                                title: 'Розподіл по сховищах',
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
                                                  color: Color(0xFF374151),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              formatBytes(item.usedBytes),
                                              style: const TextStyle(
                                                color: Color(0xFF111827),
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
                                title: 'Використання vs Вільний простір',
                                child: _BarUsageChart(items: storageUsageItems),
                              ),
                              const SizedBox(height: 16),
                              const _SectionCard(
                                title: 'Рекомендації',
                                child: Column(
                                  children: [
                                    _TipCard(
                                      emoji: '💡',
                                      title: 'Оптимізуйте Dropbox',
                                      body:
                                          'Ваш Dropbox заповнений на 90%. Видаліть старі файли або оновіть тариф.',
                                      bg: Color(0xFFEFF6FF),
                                    ),
                                    SizedBox(height: 10),
                                    _TipCard(
                                      emoji: '✨',
                                      title: 'Використовуйте iCloud',
                                      body:
                                          'У вас є 4.2 ГБ вільного місця в iCloud. Перемістіть туди великі файли.',
                                      bg: Color(0xFFECFDF5),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.storages});

  final List<StorageUsageItem> storages;

  @override
  Widget build(BuildContext context) {
    final names = storages.map((s) => s.name).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
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
                const Text(
                  'Увага!',
                  style: TextStyle(
                    color: Color(0xFF9A3412),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$names майже заповнені. Розгляньте можливість очистки або розширення.',
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
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
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
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
      ..color = const Color(0xFFE5E7EB);

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

    final holePaint = Paint()..color = Colors.white;
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
                    color: Color(0xFF374151),
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
        const Row(
          children: [
            _LegendItem(color: Color(0xFF3B82F6), text: 'Використано (ГБ)'),
            SizedBox(width: 14),
            _LegendItem(color: Color(0xFF10B981), text: 'Вільно (ГБ)'),
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
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
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
  });

  final String emoji;
  final String title;
  final String body;
  final Color bg;

  final Color _textColor = const Color(0xFF111827);

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
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
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
