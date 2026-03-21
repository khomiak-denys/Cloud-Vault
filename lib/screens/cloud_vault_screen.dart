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
import '../screens/storage_browser_screen.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/dashboard/dashboard_recent_files_section.dart';
import '../widgets/dashboard/dashboard_storages_section.dart';
import '../widgets/loading_skeletons.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/top_summary_card.dart';

class CloudVaultScreen extends StatefulWidget {
  const CloudVaultScreen({super.key});

  @override
  State<CloudVaultScreen> createState() => _CloudVaultScreenState();
}

class _CloudVaultScreenState extends State<CloudVaultScreen> {
  static const _cacheKey = 'dashboard_bundle_v1';
  static const _cacheTtl = Duration(minutes: 2);

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

  Future<void> _load({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = appCacheStore.get<_DashboardBundle>(_cacheKey);
      if (cached != null) {
        setState(() {
          _vaultItems = cached.vaultItems;
          _recentFiles = cached.recentFiles;
          _totalUsedBytes = cached.totalUsedBytes;
          _totalBytes = cached.totalBytes;
          _isLoading = false;
        });
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final usageReportFuture = _loadUsageReportSafe();
      final results = await Future.wait([
        appApiRepository.connections(),
        appApiRepository.recentFiles(pageSize: 20),
        usageReportFuture,
      ]);

      final connections = results[0] as List<ApiConnection>;
      final files = results[1] as List<ApiFileItem>;
      final usageReport = results[2] as ApiStorageUsageReport?;
      final usage = usageReport?.connections ?? const <ApiConnection>[];
      final enrichedConnections = _mergeConnectionsWithUsage(
        connections,
        usage,
      );
      final mappedVaultItems = enrichedConnections
          .map(mapConnectionToVaultItem)
          .toList();
      final mappedRecentFiles = files.map(mapApiFileToRecentFileItem).toList();
      final totalUsedBytes =
          usageReport?.usedBytes ??
          enrichedConnections.fold<double>(
            0,
            (acc, connection) => acc + connection.usedBytes,
          );
      final totalBytes =
          usageReport?.totalBytes ??
          enrichedConnections.fold<double>(
            0,
            (acc, connection) => acc + connection.totalBytes,
          );

      appCacheStore.set<_DashboardBundle>(
        _cacheKey,
        _DashboardBundle(
          vaultItems: mappedVaultItems,
          recentFiles: mappedRecentFiles,
          totalUsedBytes: totalUsedBytes,
          totalBytes: totalBytes,
        ),
        ttl: _cacheTtl,
      );

      if (!mounted) return;
      setState(() {
        _vaultItems = mappedVaultItems;
        _recentFiles = mappedRecentFiles;
        _totalUsedBytes = totalUsedBytes;
        _totalBytes = totalBytes;
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
      await _load(forceRefresh: true);
    }
  }

  Future<ApiStorageUsageReport?> _loadUsageReportSafe() async {
    try {
      return await appApiRepository.storageUsageReport();
    } catch (_) {
      return null;
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
                onRefresh: () => _load(forceRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      TopSummaryCard(percentUsed: percentUsed),
                      DashboardStoragesSection(
                        items: _vaultItems,
                        onAddTap: () async {
                          final didStartConnect = await showAddVaultModal(
                            context,
                          );
                          if (didStartConnect) {
                            await _load(forceRefresh: true);
                          }
                        },
                        onStorageTap: (storage) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  StorageBrowserScreen(storage: storage),
                            ),
                          );
                        },
                      ),
                      if (_isLoading)
                        const DashboardLoadingSkeleton()
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

  List<ApiConnection> _mergeConnectionsWithUsage(
    List<ApiConnection> connections,
    List<ApiConnection> usage,
  ) {
    String key(ApiConnection c) =>
        '${c.id}|${c.providerId}|${c.providerName}'.toLowerCase();

    final usageByKey = {for (final item in usage) key(item): item};
    final usageById = {
      for (final item in usage)
        if (item.id.isNotEmpty) item.id.toLowerCase(): item,
    };
    final usageByProvider = {
      for (final item in usage)
        if (item.providerId.isNotEmpty) item.providerId.toLowerCase(): item,
    };
    final connectionProviderCounts = <String, int>{};
    for (final connection in connections) {
      if (connection.providerId.isEmpty) continue;
      final key = connection.providerId.toLowerCase();
      connectionProviderCounts[key] = (connectionProviderCounts[key] ?? 0) + 1;
    }
    final usageProviderCounts = <String, int>{};
    for (final item in usage) {
      if (item.providerId.isEmpty) continue;
      final key = item.providerId.toLowerCase();
      usageProviderCounts[key] = (usageProviderCounts[key] ?? 0) + 1;
    }

    return connections.map((connection) {
      final providerIdKey = connection.providerId.toLowerCase();
      final canFallbackByProvider =
          providerIdKey.isNotEmpty &&
          (connectionProviderCounts[providerIdKey] ?? 0) == 1 &&
          (usageProviderCounts[providerIdKey] ?? 0) == 1;
      final matched =
          usageByKey[key(connection)] ??
          usageById[connection.id.toLowerCase()] ??
          (canFallbackByProvider ? usageByProvider[providerIdKey] : null);

      if (matched == null) return connection;

      return ApiConnection(
        id: connection.id,
        providerId: connection.providerId,
        providerName: connection.providerName,
        usedBytes: matched.usedBytes,
        totalBytes: matched.totalBytes,
      );
    }).toList();
  }
}

class _DashboardBundle {
  const _DashboardBundle({
    required this.vaultItems,
    required this.recentFiles,
    required this.totalUsedBytes,
    required this.totalBytes,
  });

  final List<VaultItem> vaultItems;
  final List<RecentFileItem> recentFiles;
  final double totalUsedBytes;
  final double totalBytes;
}
