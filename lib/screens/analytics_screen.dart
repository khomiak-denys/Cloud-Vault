import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../api/api_exception.dart';
import '../data/storage_formatters.dart';
import '../state/providers/analytics_provider.dart';
import '../theme/app_theme_colors.dart';
import '../utils/tab_navigation.dart';
import '../widgets/analytics/analytics_components.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/loading_skeletons.dart';
import '../widgets/mobile_screen_shell.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final analyticsProvider = context.read<AnalyticsProvider>();

    try {
      await analyticsProvider.ensureLoaded(forceRefresh: forceRefresh);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to load analytics');
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

  Future<void> _exportPdfReport() async {
    final l10n = AppLocalizations.of(context)!;
    final analyticsProvider = context.read<AnalyticsProvider>();
    final usageItems = analyticsProvider.usageItems;
    final recommendations = analyticsProvider.recommendations;
    try {
      final now = DateTime.now();
      final generatedAt = DateFormat('yyyy-MM-dd HH:mm').format(now);
      final fileSuffix = DateFormat('yyyyMMdd-HHmm').format(now);
      final totalUsed = usageItems.fold<double>(
        0,
        (acc, item) => acc + item.usedBytes,
      );
      final totalSpace = usageItems.fold<double>(
        0,
        (acc, item) => acc + item.totalBytes,
      );
      final totalFree = totalSpace - totalUsed;
      final baseFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
      );
      final boldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
      );

      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
          build: (context) => [
            pw.Text(
              l10n.pdfReportTitle,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('${l10n.generatedAt}: $generatedAt'),
            pw.SizedBox(height: 16),
            pw.Text('${l10n.totalSpace}: ${formatBytes(totalSpace)}'),
            pw.Text('${l10n.usedSpace}: ${formatBytes(totalUsed)}'),
            pw.Text('${l10n.freeSpace}: ${formatBytes(totalFree)}'),
            pw.SizedBox(height: 18),
            pw.Text(
              l10n.distributionByStorage,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...usageItems.map((item) {
              final percent = totalUsed > 0
                  ? ((item.usedBytes / totalUsed) * 100)
                  : 0.0;
              final percentText = percent.toStringAsFixed(1);
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                  '${item.name}: ${formatBytes(item.usedBytes)} / ${formatBytes(item.totalBytes)} ($percentText%)',
                ),
              );
            }),
            pw.SizedBox(height: 18),
            pw.Text(
              l10n.recommendations,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (recommendations.isEmpty)
              pw.Text('-')
            else
              ...recommendations
                  .take(5)
                  .map(
                    (item) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Bullet(text: '${item.title}: ${item.body}'),
                    ),
                  ),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'cloud-vault-report-$fileSuffix.pdf',
      );
    } catch (_) {
      if (!mounted) return;
      _showSnack(l10n.pdfExportFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppThemeColors.of(context);
    final analyticsProvider = context.watch<AnalyticsProvider>();
    final usageItems = analyticsProvider.usageItems;
    final recommendations = analyticsProvider.recommendations;
    final isLoading = analyticsProvider.isLoading;

    final totalUsed = usageItems.fold<double>(
      0,
      (acc, item) => acc + item.usedBytes,
    );
    final totalSpace = usageItems.fold<double>(
      0,
      (acc, item) => acc + item.totalBytes,
    );
    final totalFree = totalSpace - totalUsed;
    final almostFullStorages = usageItems
        .where((s) => s.usagePercent >= 90)
        .toList();

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: const AnalyticsLoadingSkeleton(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(forceRefresh: true),
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
                              AnalyticsWarningCard(
                                storages: almostFullStorages,
                              ),
                              const SizedBox(height: 16),
                            ],
                            AnalyticsSectionCard(
                              title: l10n.distributionByStorage,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 220,
                                    child: AnalyticsPieUsageChart(
                                      items: usageItems,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...usageItems.map(
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
                              child: AnalyticsBarUsageChart(items: usageItems),
                            ),
                            const SizedBox(height: 16),
                            AnalyticsSectionCard(
                              title: l10n.recommendations,
                              child: Column(
                                children: recommendations.isEmpty
                                    ? [
                                        AnalyticsTipCard(
                                          emoji: 'i',
                                          title: 'No recommendations available',
                                          body:
                                              'The backend did not return storage optimization tips.',
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
                                    : recommendations.take(2).map((r) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
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
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: usageItems.isEmpty
                                    ? null
                                    : _exportPdfReport,
                                icon: const Icon(Icons.picture_as_pdf_outlined),
                                label: Text(l10n.exportPdf),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      colors.secondaryButtonBackground,
                                  foregroundColor:
                                      colors.secondaryButtonForeground,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  overlayColor: Colors.transparent,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
