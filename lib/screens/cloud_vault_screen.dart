import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../api/api_repository.dart';
import '../data/api_mappers.dart';
import '../data/app_services.dart';
import '../data/file_actions_handler.dart';
import '../modals/add_vault_modal.dart';
import '../modals/file_actions_modal.dart';
import '../models/recent_file_item.dart';
import '../models/vault_item.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/dashboard/dashboard_recent_files_section.dart';
import '../widgets/dashboard/dashboard_storages_section.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/top_summary_card.dart';

class CloudVaultScreen extends StatefulWidget {
  const CloudVaultScreen({super.key});

  @override
  State<CloudVaultScreen> createState() => _CloudVaultScreenState();
}

class _CloudVaultScreenState extends State<CloudVaultScreen> {
  List<VaultItem> _vaultItems = const [];
  List<RecentFileItem> _recentFiles = const [];
  bool _isLoading = true;
  double _totalUsedBytes = 0;
  double _totalBytes = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        appApiRepository.connections(),
        appApiRepository.recentFiles(pageSize: 20),
      ]);

      final connections = results[0] as List<ApiConnection>;
      final files = results[1] as List<ApiFileItem>;

      if (!mounted) return;
      setState(() {
        _vaultItems = connections.map(mapConnectionToVaultItem).toList();
        _recentFiles = files.map(mapApiFileToRecentFileItem).toList();
        _totalUsedBytes = connections.fold<double>(
          0,
          (acc, connection) => acc + connection.usedBytes,
        );
        _totalBytes = connections.fold<double>(
          0,
          (acc, connection) => acc + connection.totalBytes,
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to load dashboard data');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onFileAction(String actionId, RecentFileItem file) async {
    final shouldReload = await handleFileAction(context, actionId, file);
    if (shouldReload) {
      await _load();
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
    final percentUsed = _totalBytes > 0
        ? (_totalUsedBytes / _totalBytes).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      TopSummaryCard(percentUsed: percentUsed),
                      DashboardStoragesSection(
                        items: _vaultItems,
                        onAddTap: () async {
                          await showAddVaultModal(context);
                          await _load();
                        },
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        )
                      else
                        DashboardRecentFilesSection(
                          items: _recentFiles,
                          onMoreTap: (file) => showFileActionsModal(
                            context,
                            file,
                            onActionTap: _onFileAction,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            BottomNavBar(
              activeIndex: 0,
              onTap: (index) => handleBottomNavTap(context, 0, index),
            ),
          ],
        ),
      ),
    );
  }
}
