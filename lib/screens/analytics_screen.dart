import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/storage_formatters.dart';
import '../data/storage_usage_mock_data.dart';
import '../theme/app_theme_colors.dart';
import '../utils/tab_navigation.dart';
import '../widgets/analytics/analytics_components.dart';
import '../widgets/app_page_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mobile_screen_shell.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppThemeColors.of(context);

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
                          child: AnalyticsStatCard(
                            icon: Icons.storage,
                            label: l10n.totalSpace,
                            value: formatBytes(totalSpace),
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFDBEAFE),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnalyticsStatCard(
                            icon: Icons.task_alt,
                            label: l10n.usedSpace,
                            value: formatBytes(totalUsed),
                            iconColor: const Color(0xFF16A34A),
                            iconBg: const Color(0xFFDCFCE7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnalyticsStatCard(
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
                      AnalyticsWarningCard(storages: almostFullStorages),
                      const SizedBox(height: 16),
                    ],
                    AnalyticsSectionCard(
                      title: l10n.distributionByStorage,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: AnalyticsPieUsageChart(
                              items: storageUsageItems,
                            ),
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
                                      style: TextStyle(
                                        color: colors.secondaryText,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatBytes(item.usedBytes),
                                    style: TextStyle(
                                      color: colors.primaryText,
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
                    AnalyticsSectionCard(
                      title: l10n.usageVsFree,
                      child: AnalyticsBarUsageChart(items: storageUsageItems),
                    ),
                    const SizedBox(height: 16),
                    AnalyticsSectionCard(
                      title: l10n.recommendations,
                      child: Column(
                        children: [
                          AnalyticsTipCard(
                            emoji: '💡',
                            title: l10n.tipOptimizeDropboxTitle,
                            body: l10n.tipOptimizeDropboxBody,
                            bg: isDark
                                ? const Color(0xFF182A4A)
                                : const Color(0xFFEAF2FF),
                            titleColor: isDark
                                ? const Color(0xFFEAF2FF)
                                : const Color(0xFF0F172A),
                            bodyColor: isDark
                                ? const Color(0xFF98A8BF)
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(height: 10),
                          AnalyticsTipCard(
                            emoji: '✨',
                            title: l10n.tipUseIcloudTitle,
                            body: l10n.tipUseIcloudBody,
                            bg: isDark
                                ? const Color(0xFF18323A)
                                : const Color(0xFFEAF9F2),
                            titleColor: isDark
                                ? const Color(0xFFEAF2FF)
                                : const Color(0xFF0F172A),
                            bodyColor: isDark
                                ? const Color(0xFF98A8BF)
                                : const Color(0xFF475569),
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
