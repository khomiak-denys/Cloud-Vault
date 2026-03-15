import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../api/api_repository.dart';
import '../data/api_mappers.dart';
import '../data/app_services.dart';
import '../data/storage_formatters.dart';
import '../models/storage_usage_item.dart';
import '../theme/app_theme_colors.dart';
import '../utils/tab_navigation.dart';
import '../widgets/analytics/analytics_components.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mobile_screen_shell.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<StorageUsageItem> _usageItems = const [];
  List<ApiStorageRecommendation> _recommendations = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        appApiRepository.storageUsage(),
        appApiRepository.recommendations(),
      ]);

      final usage = results[0] as List<ApiConnection>;
      final recommendations = results[1] as List<ApiStorageRecommendation>;

      if (!mounted) return;
      setState(() {
        _usageItems = usage.map(mapConnectionToStorageUsageItem).toList();
        _recommendations = recommendations;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to load analytics');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppThemeColors.of(context);

    final totalUsed = _usageItems.fold<double>(0, (acc, item) => acc + item.usedBytes);
    final totalSpace = _usageItems.fold<double>(0, (acc, item) => acc + item.totalBytes);
    final totalFree = totalSpace - totalUsed;
    final almostFullStorages = _usageItems.where((s) => s.usagePercent >= 90).toList();

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                    child: AnalyticsPieUsageChart(items: _usageItems),
                                  ),
                                  const SizedBox(height: 10),
                                  ..._usageItems.map(
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
                              child: AnalyticsBarUsageChart(items: _usageItems),
                            ),
                            const SizedBox(height: 16),
                            AnalyticsSectionCard(
                              title: l10n.recommendations,
                              child: Column(
                                children: _recommendations.isEmpty
                                    ? [
                                        AnalyticsTipCard(
                                          emoji: 'i',
                                          title: 'No recommendations available',
                                          body: 'The backend did not return storage optimization tips.',
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
                                      ]
                                    : _recommendations.take(2).map((r) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: AnalyticsTipCard(
                                            emoji: '*',
                                            title: r.title,
                                            body: r.body,
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
                                        );
                                      }).toList(),
                              ),
                            ),
                          ],
                        ),
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
